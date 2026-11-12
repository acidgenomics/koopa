"""Build and install domain-hosted koopa release archives."""

import fcntl
import gzip
import hashlib
import io
import json
import re
import shutil
import subprocess
import tarfile
import tempfile
import tomllib
from pathlib import Path, PurePosixPath

_BASE_URL = "https://koopa.acidgenomics.com/releases"
_MARKER = ".koopa-release.json"
_TAG = re.compile(r"v[0-9]+\.[0-9]+\.[0-9]+\Z")


def _digest(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def _version(tag: str) -> tuple[int, ...]:
    if not _TAG.fullmatch(tag):
        raise ValueError(f"Not a stable release tag: {tag!r}")
    return tuple(int(part) for part in tag[1:].split("."))


def _safe_name(name: str) -> str:
    path = PurePosixPath(name)
    if (
        not name
        or not path.parts
        or str(path) != name.rstrip("/")
        or path.is_absolute()
        or any(x in (".", "..") for x in path.parts)
        or path.parts[0] in (".git", ".env", ".venv", ".koopa-release-transaction", "app", "opt")
    ):
        raise ValueError(f"Unsafe release archive path: {name!r}")
    return str(path)


def _read_archive(path: Path) -> tuple[dict[str, bytes], dict[str, int], dict]:
    files: dict[str, bytes] = {}
    modes: dict[str, int] = {}
    with tarfile.open(path, "r:gz") as archive:
        for member in archive:
            name = _safe_name(member.name)
            if member.isdir():
                continue
            if not member.isfile() or name in files:
                raise ValueError(f"Unsupported or duplicate archive member: {name}")
            stream = archive.extractfile(member)
            if stream is None:
                raise ValueError(f"Missing archive member: {name}")
            files[name] = stream.read()
            modes[name] = member.mode & 0o777
    try:
        metadata = json.loads(files.pop(_MARKER))
        modes.pop(_MARKER)
    except (KeyError, ValueError) as exc:
        raise ValueError("Invalid release metadata.") from exc
    if (
        not isinstance(metadata, dict)
        or not isinstance(metadata.get("version"), str)
        or not _TAG.fullmatch(metadata["version"])
        or metadata.get("files") != {name: _digest(data) for name, data in files.items()}
    ):
        raise ValueError("Release metadata does not match archive contents.")
    return files, modes, metadata


def build_archive(root: str, tag: str, destination: str) -> str:
    """Build a release archive from a committed Git tag.

    Parameters
    ----------
    root : str
        Git repository root.
    tag : str
        Stable version tag.
    destination : str
        Output archive path.

    Returns
    -------
    str
        SHA-256 digest of the archive.
    """
    _version(tag)
    with tempfile.TemporaryDirectory() as tmp:
        raw = Path(tmp) / "source.tar"
        with raw.open("wb") as out:
            subprocess.run(
                ["git", "archive", "--format=tar", tag],
                cwd=root,
                stdout=out,
                check=True,
            )
        files: dict[str, bytes] = {}
        modes: dict[str, int] = {}
        with tarfile.open(raw) as archive:
            for member in archive:
                name = _safe_name(member.name)
                if member.isdir():
                    continue
                if not member.isfile() or name in files or name == _MARKER:
                    raise ValueError(f"Unsupported or duplicate archive member: {name}")
                stream = archive.extractfile(member)
                if stream is None:
                    raise ValueError(f"Missing archive member: {name}")
                files[name] = stream.read()
                modes[name] = member.mode & 0o777
        version = tomllib.loads(files["pyproject.toml"].decode())["project"]["version"]
        if tag != f"v{version}":
            raise ValueError(f"Tag {tag} does not match project version {version}.")
        metadata = {"version": tag, "files": {name: _digest(data) for name, data in files.items()}}
        files[_MARKER] = json.dumps(metadata, sort_keys=True).encode() + b"\n"
        modes[_MARKER] = 0o644
        with (
            Path(destination).open("wb") as raw_out,
            gzip.GzipFile(filename="", mode="wb", fileobj=raw_out, mtime=0) as compressed,
            tarfile.open(fileobj=compressed, mode="w") as archive,
        ):
            for name in sorted(files):
                data = files[name]
                member = tarfile.TarInfo(name)
                member.size = len(data)
                member.mode = modes[name]
                archive.addfile(member, io.BytesIO(data))
    _read_archive(Path(destination))
    return _digest(Path(destination).read_bytes())


def publish_release(tag: str) -> None:
    """Publish a stable tagged release and its installer to the koopa site.

    Parameters
    ----------
    tag : str
        Stable version tag already merged into main.
    """
    from koopa.prefix import koopa_prefix
    from koopa.site import _aws, _bucket, _invalidate_cloudfront

    _version(tag)
    root = koopa_prefix()
    aws = _aws()
    bucket = _bucket()
    subprocess.run(
        ["git", "merge-base", "--is-ancestor", tag, "refs/heads/main"],
        cwd=root,
        check=True,
    )
    with tempfile.TemporaryDirectory() as tmp:
        listing = subprocess.run(
            [
                aws,
                "s3api",
                "list-objects-v2",
                "--bucket",
                bucket,
                "--prefix",
                "releases/latest",
                "--max-keys",
                "1",
                "--output",
                "json",
                "--profile",
                "acidgenomics",
                "--no-cli-pager",
            ],
            capture_output=True,
            text=True,
            check=True,
        )
        objects = json.loads(listing.stdout).get("Contents", [])
        if any(obj["Key"] == "releases/latest" for obj in objects):
            previous = Path(tmp) / "previous"
            subprocess.run(
                [
                    aws,
                    "s3",
                    "cp",
                    f"s3://{bucket}/releases/latest",
                    str(previous),
                    "--profile",
                    "acidgenomics",
                    "--only-show-errors",
                ],
                check=True,
            )
            previous_tag, _ = _read_latest(previous)
            if _version(tag) < _version(previous_tag):
                raise ValueError(f"Cannot replace latest {previous_tag} with older release {tag}.")
        archive = Path(tmp) / "koopa.tar.gz"
        checksum = build_archive(root, tag, str(archive))
        manifest = Path(tmp) / "manifest"
        manifest.write_text(f"{tag} {checksum}\n")
        installer = Path(tmp) / "install-release"
        with installer.open("wb") as out:
            subprocess.run(
                ["git", "show", f"{tag}:install-release.sh"],
                cwd=root,
                stdout=out,
                check=True,
            )
        for path, key in (
            (archive, f"releases/{tag}/koopa.tar.gz"),
            (manifest, f"releases/{tag}/manifest"),
        ):
            command = [
                aws,
                "s3api",
                "put-object",
                "--bucket",
                bucket,
                "--key",
                key,
                "--body",
                str(path),
                "--if-none-match",
                "*",
                "--profile",
                "acidgenomics",
                "--no-cli-pager",
            ]
            try:
                subprocess.run(command, check=True, stdout=subprocess.DEVNULL)
            except subprocess.CalledProcessError:
                existing = Path(tmp) / "existing"
                subprocess.run(
                    [
                        aws,
                        "s3",
                        "cp",
                        f"s3://{bucket}/{key}",
                        str(existing),
                        "--profile",
                        "acidgenomics",
                        "--only-show-errors",
                    ],
                    check=True,
                )
                if existing.read_bytes() != path.read_bytes():
                    raise ValueError(f"Existing release object differs: {key}") from None
        for path, key in ((installer, "install-release"), (manifest, "releases/latest")):
            subprocess.run(
                [
                    aws,
                    "s3",
                    "cp",
                    str(path),
                    f"s3://{bucket}/{key}",
                    "--cache-control",
                    "no-cache",
                    "--profile",
                    "acidgenomics",
                    "--only-show-errors",
                ],
                check=True,
            )
        _invalidate_cloudfront()


def _download(url: str, destination: Path) -> None:
    from koopa.download import download

    download(url, str(destination), quiet=True, connect_timeout=15, max_time=300)


def _read_latest(path: Path) -> tuple[str, str]:
    parts = path.read_text().split()
    if (
        len(parts) != 2
        or not _TAG.fullmatch(parts[0])
        or not re.fullmatch(r"[a-f0-9]{64}", parts[1])
    ):
        raise ValueError("Invalid latest release manifest.")
    return parts[0], parts[1]


def _check_path(root: Path, name: str) -> Path:
    path = root / _safe_name(name)
    for parent in path.parents:
        if parent == root:
            break
        if parent.is_symlink() or (parent.exists() and not parent.is_dir()):
            raise ValueError(f"Unsafe release path: {path}")
    return path


def _restore(root: Path, transaction: Path) -> None:
    record = json.loads((transaction / "record.json").read_text())
    for name in record["paths"]:
        target = _check_path(root, name)
        backup = transaction / "backup" / name
        if backup.is_file():
            target.parent.mkdir(parents=True, exist_ok=True)
            staged = transaction / "restore" / name
            staged.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(backup, staged)
            staged.replace(target)
        elif target.is_file() or target.is_symlink():
            target.unlink()
    shutil.rmtree(transaction)


def recover_release(prefix: str) -> None:
    """Recover an interrupted release update before loading koopa modules.

    Parameters
    ----------
    prefix : str
        Installed koopa prefix.
    """
    root = Path(prefix)
    transaction = root / ".koopa-release-transaction"
    if not transaction.exists():
        return
    sentinel = transaction / "owner"
    if not sentinel.is_file() or sentinel.read_text() != "koopa release transaction v1\n":
        raise ValueError(f"Unrecognized release transaction directory: {transaction}")
    with (transaction / "lock").open("r") as lock:
        try:
            fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
        except BlockingIOError as exc:
            raise RuntimeError("A release update is running.") from exc
        if (transaction / "record.json").is_file():
            _restore(root, transaction)
        else:
            shutil.rmtree(transaction)


def update_release(prefix: str) -> bool:
    """Update an archive installation to the latest published stable release.

    Parameters
    ----------
    prefix : str
        Installed koopa prefix.

    Returns
    -------
    bool
        Whether the release was updated.
    """
    root = Path(prefix)
    transaction = root / ".koopa-release-transaction"
    recover_release(prefix)
    marker = root / _MARKER
    current = json.loads(marker.read_text())
    if (
        not isinstance(current, dict)
        or not isinstance(current.get("version"), str)
        or not isinstance(current.get("files"), dict)
    ):
        raise ValueError("Invalid installed release metadata.")
    installed_version = _version(current["version"])
    with tempfile.TemporaryDirectory() as tmp:
        latest = Path(tmp) / "latest"
        _download(f"{_BASE_URL}/latest", latest)
        version, checksum = _read_latest(latest)
        if current.get("version") == version:
            return False
        if _version(version) < installed_version:
            raise ValueError(
                f"Latest release {version} is older than installed {current['version']}."
            )
        archive = Path(tmp) / "koopa.tar.gz"
        _download(f"{_BASE_URL}/{version}/koopa.tar.gz", archive)
        if _digest(archive.read_bytes()) != checksum:
            raise ValueError("Release archive checksum mismatch.")
        files, modes, metadata = _read_archive(archive)
        if metadata["version"] != version:
            raise ValueError("Release archive version does not match manifest.")
        old = current["files"]
        names = sorted(set(old) | set(files))
        for name in names:
            target = _check_path(root, name)
            if name in old:
                if (
                    not target.is_file()
                    or target.is_symlink()
                    or _digest(target.read_bytes()) != old[name]
                ):
                    raise ValueError(f"Locally modified release file: {target}")
            elif target.exists() or target.is_symlink():
                raise ValueError(f"Release would overwrite an unmanaged path: {target}")
        transaction.mkdir()
        lock = (transaction / "lock").open("w")
        try:
            fcntl.flock(lock, fcntl.LOCK_EX)
            (transaction / "owner").write_text("koopa release transaction v1\n")
            for name in [*old, _MARKER]:
                source = _check_path(root, name)
                backup = transaction / "backup" / name
                backup.parent.mkdir(parents=True, exist_ok=True)
                shutil.copy2(source, backup)
            for name, data in files.items():
                staged = transaction / "next" / name
                staged.parent.mkdir(parents=True, exist_ok=True)
                staged.write_bytes(data)
                staged.chmod(modes[name])
            staged_marker = transaction / "next" / _MARKER
            staged_marker.write_text(json.dumps(metadata, sort_keys=True) + "\n")
            record = {"paths": [*names, _MARKER]}
            record_tmp = transaction / "record.tmp"
            record_tmp.write_text(json.dumps(record))
            record_tmp.replace(transaction / "record.json")
            for name in names:
                target = _check_path(root, name)
                if name not in files:
                    target.unlink()
                    continue
                target.parent.mkdir(parents=True, exist_ok=True)
                (transaction / "next" / name).replace(target)
            staged_marker.replace(marker)
        except Exception:
            if (transaction / "record.json").is_file():
                _restore(root, transaction)
            else:
                shutil.rmtree(transaction)
            raise
        else:
            shutil.rmtree(transaction)
        finally:
            lock.close()
    return True
