"""Tests for domain-hosted koopa releases."""

import fcntl
import hashlib
import io
import json
import os
import shutil
import subprocess
import sys
import tarfile
from pathlib import Path
from typing import IO, cast

import pytest
from koopa import release


def _build(
    monkeypatch: pytest.MonkeyPatch,
    destination: Path,
    tag: str,
    files: dict[str, bytes],
) -> str:
    files = {"pyproject.toml": f'[project]\nversion = "{tag[1:]}"\n'.encode(), **files}

    def archive(_args: list[str], *, cwd: str, stdout: IO[bytes], check: bool) -> None:
        assert check
        assert cwd
        with tarfile.open(fileobj=stdout, mode="w") as tar:
            for name, data in files.items():
                member = tarfile.TarInfo(name)
                member.size = len(data)
                member.mode = 0o755 if name.startswith("bin/") else 0o644
                tar.addfile(member, io.BytesIO(data))

    with monkeypatch.context() as patch:
        patch.setattr(subprocess, "run", archive)
        return release.build_archive(".", tag, str(destination))


def _install(archive: Path, root: Path) -> None:
    files, modes, metadata = release._read_archive(archive)
    root.mkdir()
    for name, content in files.items():
        path = root / name
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_bytes(content)
        path.chmod(modes[name])
    (root / release._MARKER).write_text(json.dumps(metadata))


def _set_downloads(
    monkeypatch: pytest.MonkeyPatch,
    archive: Path,
    version: str,
    digest: str,
) -> None:
    def download(url: str, destination: Path) -> None:
        if url.endswith("/latest"):
            destination.write_text(f"{version} {digest}\n")
        else:
            assert url.endswith(f"/{version}/koopa.tar.gz")
            destination.write_bytes(archive.read_bytes())

    monkeypatch.setattr(release, "_download", download)


def test_release_update_preserves_unmanaged_files(
    tmp_path: Path, monkeypatch: pytest.MonkeyPatch
) -> None:
    """Update managed files without replacing runtime data."""
    old = tmp_path / "old.tar.gz"
    new = tmp_path / "new.tar.gz"
    _build(monkeypatch, old, "v1.0.0", {"bin/koopa": b"old", "removed": b"old"})
    digest = _build(monkeypatch, new, "v1.1.0", {"bin/koopa": b"new", "added": b"new"})
    root = tmp_path / "installed"
    _install(old, root)
    (root / "app").mkdir()
    (root / "app" / "data").write_text("keep")
    (root / "bin" / "local").write_text("keep")
    _set_downloads(monkeypatch, new, "v1.1.0", digest)

    assert release.update_release(str(root))
    assert (root / "bin" / "koopa").read_bytes() == b"new"
    assert (root / "bin" / "koopa").stat().st_mode & 0o111
    assert not (root / "removed").exists()
    assert (root / "added").read_bytes() == b"new"
    assert (root / "app" / "data").read_text() == "keep"
    assert (root / "bin" / "local").read_text() == "keep"
    assert not release.update_release(str(root))


@pytest.mark.parametrize("conflict", ["modified", "unmanaged", "checksum"])
def test_release_update_rejects_conflicts(
    tmp_path: Path, monkeypatch: pytest.MonkeyPatch, conflict: str
) -> None:
    """Reject modified files, unmanaged collisions, and invalid checksums."""
    old = tmp_path / "old.tar.gz"
    new = tmp_path / "new.tar.gz"
    _build(monkeypatch, old, "v1.0.0", {"file": b"old"})
    digest = _build(monkeypatch, new, "v1.1.0", {"file": b"new", "added": b"new"})
    root = tmp_path / "installed"
    _install(old, root)
    if conflict == "modified":
        (root / "file").write_bytes(b"custom")
    elif conflict == "unmanaged":
        (root / "added").write_bytes(b"custom")
    else:
        digest = "0" * 64
    _set_downloads(monkeypatch, new, "v1.1.0", digest)

    with pytest.raises(ValueError, match=r"modified|unmanaged|checksum"):
        release.update_release(str(root))
    assert json.loads((root / release._MARKER).read_text())["version"] == "v1.0.0"


def test_release_update_rejects_older_latest(
    tmp_path: Path, monkeypatch: pytest.MonkeyPatch
) -> None:
    """A stale manifest must never downgrade an installed release."""
    archive = tmp_path / "release.tar.gz"
    digest = _build(monkeypatch, archive, "v1.1.0", {"file": b"current"})
    root = tmp_path / "installed"
    _install(archive, root)
    _set_downloads(monkeypatch, archive, "v1.0.0", digest)
    with pytest.raises(ValueError, match="older than installed"):
        release.update_release(str(root))
    assert (root / "file").read_bytes() == b"current"


def test_release_archive_is_reproducible(tmp_path: Path, monkeypatch: pytest.MonkeyPatch) -> None:
    """Republishing the same tag produces the same immutable object."""
    first = tmp_path / "first.tar.gz"
    second = tmp_path / "second.tar.gz"
    digest = _build(monkeypatch, first, "v1.0.0", {"file": b"content"})
    assert digest == _build(monkeypatch, second, "v1.0.0", {"file": b"content"})
    assert first.read_bytes() == second.read_bytes()


def test_interrupted_transaction_is_restored(
    tmp_path: Path, monkeypatch: pytest.MonkeyPatch
) -> None:
    """Recover a transaction interrupted after files were replaced."""
    old = tmp_path / "old.tar.gz"
    _build(monkeypatch, old, "v1.0.0", {"file": b"old"})
    root = tmp_path / "installed"
    _install(old, root)
    transaction = root / ".koopa-release-transaction"
    backup = transaction / "backup"
    backup.mkdir(parents=True)
    (transaction / "owner").write_text("koopa release transaction v1\n")
    (transaction / "lock").touch()
    (backup / "file").write_bytes(b"old")
    (backup / release._MARKER).write_bytes((root / release._MARKER).read_bytes())
    (transaction / "record.json").write_text(
        json.dumps({"paths": ["file", "added", release._MARKER]})
    )
    (root / "file").write_bytes(b"partly updated")
    (root / "added").write_bytes(b"new")
    _set_downloads(monkeypatch, old, "v1.0.0", "0" * 64)

    assert not release.update_release(str(root))
    assert (root / "file").read_bytes() == b"old"
    assert not (root / "added").exists()
    assert not transaction.exists()


def test_running_transaction_is_not_rolled_back(tmp_path: Path) -> None:
    """A second process must not recover an update that is still running."""
    transaction = tmp_path / ".koopa-release-transaction"
    transaction.mkdir()
    (transaction / "owner").write_text("koopa release transaction v1\n")
    with (transaction / "lock").open("w") as lock:
        fcntl.flock(lock, fcntl.LOCK_EX)
        with pytest.raises(RuntimeError, match="update is running"):
            release.recover_release(str(tmp_path))
    assert transaction.is_dir()


def test_failed_update_restores_previous_release(
    tmp_path: Path, monkeypatch: pytest.MonkeyPatch
) -> None:
    """Roll back already replaced files when a later replacement fails."""
    old = tmp_path / "old.tar.gz"
    new = tmp_path / "new.tar.gz"
    _build(monkeypatch, old, "v1.0.0", {"one": b"old", "two": b"old"})
    digest = _build(monkeypatch, new, "v1.1.0", {"one": b"new", "two": b"new"})
    root = tmp_path / "installed"
    _install(old, root)
    _set_downloads(monkeypatch, new, "v1.1.0", digest)
    replace = Path.replace

    def fail_second(path: Path, target: str | os.PathLike[str]) -> Path:
        if path.name == "two" and path.parent.name == "next":
            raise OSError("simulated failure")
        return replace(path, target)

    monkeypatch.setattr(Path, "replace", fail_second)
    with pytest.raises(OSError, match="simulated failure"):
        release.update_release(str(root))
    assert (root / "one").read_bytes() == b"old"
    assert (root / "two").read_bytes() == b"old"
    assert not (root / ".koopa-release-transaction").exists()


def test_publisher_uploads_immutable_artifacts_before_latest(
    tmp_path: Path, monkeypatch: pytest.MonkeyPatch
) -> None:
    """Publish immutable objects before advancing the stable channel."""
    import koopa.prefix
    import koopa.site

    commands: list[list[str]] = []
    monkeypatch.setattr(koopa.prefix, "koopa_prefix", lambda: str(tmp_path))
    monkeypatch.setattr(koopa.site, "_aws", lambda: "aws")
    monkeypatch.setattr(koopa.site, "_bucket", lambda: "test-bucket")
    monkeypatch.setattr(
        koopa.site, "_invalidate_cloudfront", lambda: commands.append(["invalidate"])
    )

    def build(_root: str, _tag: str, destination: str) -> str:
        Path(destination).write_bytes(b"archive")
        return "a" * 64

    def run(args: list[str], **kwargs: object) -> subprocess.CompletedProcess[str]:
        commands.append(args)
        if args[:2] == ["git", "show"]:
            cast("IO[bytes]", kwargs["stdout"]).write(b"installer")
        output = '{"Contents": []}' if "list-objects-v2" in args else ""
        return subprocess.CompletedProcess(args, 0, stdout=output)

    monkeypatch.setattr(release, "build_archive", build)
    monkeypatch.setattr(subprocess, "run", run)
    release.publish_release("v1.0.0")
    uploads = [command for command in commands if "put-object" in command]
    assert len(uploads) == 2
    assert all("--if-none-match" in command for command in uploads)
    assert commands[-2][0:3] == ["aws", "s3", "cp"]
    assert commands[-2][4] == "s3://test-bucket/releases/latest"
    assert commands[-1] == ["invalidate"]


def test_launcher_recovers_before_importing_koopa(tmp_path: Path) -> None:
    """The launcher restores interrupted updates even when live code is broken."""
    root = tmp_path / "installed"
    (root / "bin").mkdir(parents=True)
    source = Path(__file__).resolve().parents[3]
    shutil.copy2(source / "bin" / "koopa", root / "bin" / "koopa")
    python = root / ".venv" / "bin" / "python3"
    python.parent.mkdir(parents=True)
    python.symlink_to(sys.executable)
    (root / ".python-version").write_text(f"{sys.version_info.major}.{sys.version_info.minor}\n")
    package = root / "lang" / "python" / "src" / "koopa"
    package.mkdir(parents=True)
    (package / "__init__.py").write_text("")
    (package / "cli_main.py").write_text("raise RuntimeError('broken update')\n")
    transaction = root / ".koopa-release-transaction"
    backup = transaction / "backup"
    recovery = backup / "lang" / "python" / "src" / "koopa" / "release.py"
    recovery.parent.mkdir(parents=True)
    shutil.copy2(source / "lang" / "python" / "src" / "koopa" / "release.py", recovery)
    (recovery.parent / "cli_main.py").write_text("print('recovered')\n")
    (transaction / "owner").write_text("koopa release transaction v1\n")
    (transaction / "lock").touch()
    (transaction / "record.json").write_text(
        json.dumps({"paths": ["lang/python/src/koopa/cli_main.py"]})
    )
    env = {**os.environ, "KOOPA_BOOTSTRAP_PREFIX": "", "PYTHONPATH": ""}
    result = subprocess.run(
        [str(root / "bin" / "koopa")], env=env, capture_output=True, text=True, check=True
    )
    assert result.stdout.strip() == "recovered"
    assert not transaction.exists()


def test_archive_rejects_reserved_runtime_paths(
    tmp_path: Path, monkeypatch: pytest.MonkeyPatch
) -> None:
    """Prevent release archives from owning application data."""
    with pytest.raises(ValueError, match="Unsafe release archive path"):
        _build(monkeypatch, tmp_path / "release.tar.gz", "v1.0.0", {"app/data": b"unsafe"})


@pytest.mark.parametrize("valid", [True, False])
def test_installer_fetches_release_without_github(tmp_path: Path, valid: bool) -> None:
    """Install from the domain only and reject a corrupt download before execution."""
    fakebin = tmp_path / "fakebin"
    fakebin.mkdir()
    scripts = {
        "curl": """#!/bin/sh
output=''
url=''
while [ "$#" -gt 0 ]
do
    case "$1" in
        -o) output="$2"; shift ;;
        https://*) url="$1" ;;
    esac
    shift
done
printf '%s\\n' "$url" >> "${HOME}/urls"
case "$url" in
    */manifest) cp "${HOME}/manifest" "$output" ;;
    */koopa.tar.gz) cp "${HOME}/archive" "$output" ;;
    *) exit 1 ;;
esac
""",
        "id": '#!/bin/sh\ncase "$1" in -Gn) echo users ;; -u) echo 1000 ;; esac\n',
        "uname": "#!/bin/sh\necho Linux\n",
    }
    for name, script in scripts.items():
        path = fakebin / name
        path.write_text(script)
        path.chmod(0o755)
    archive = tmp_path / "archive"
    with tarfile.open(archive, "w:gz") as tar:
        for name, content in (
            ("bootstrap.sh", b'printf "%s" "$PREFIX" > "$HOME/booted"\n'),
            ("bin/koopa", b'#!/bin/sh\nprintf "%s" "$*" > "$HOME/installed"\n'),
        ):
            member = tarfile.TarInfo(name)
            member.mode = 0o755
            member.size = len(content)
            tar.addfile(member, io.BytesIO(content))
    digest = hashlib.sha256(archive.read_bytes()).hexdigest() if valid else "0" * 64
    (tmp_path / "manifest").write_text(f"v1.0.0 {digest}\n")
    env = {
        **os.environ,
        "HOME": str(tmp_path),
        "XDG_DATA_HOME": str(tmp_path / "data"),
        "PATH": f"{fakebin}:/usr/bin:/bin",
    }
    installer = Path(__file__).resolve().parents[3] / "install-release.sh"
    if valid:
        subprocess.run(["sh", str(installer), "--version", "1.0.0"], env=env, check=True)
        assert (tmp_path / "installed").read_text() == "install koopa"
        assert (tmp_path / "booted").read_text() == str(tmp_path / "data" / "koopa-bootstrap")
    else:
        with pytest.raises(subprocess.CalledProcessError):
            subprocess.run(
                ["sh", str(installer), "--version", "1.0.0"],
                env=env,
                check=True,
                capture_output=True,
            )
        assert not (tmp_path / "booted").exists()
    assert all(
        line.startswith("https://koopa.acidgenomics.com/releases/")
        for line in (tmp_path / "urls").read_text().splitlines()
    )
