"""Lig release installer tests."""

import hashlib
import io
import subprocess
import tarfile
from pathlib import Path
from unittest.mock import Mock

import pytest
from koopa import install
from koopa.installers import lig
from koopa.io import import_app_json


@pytest.mark.parametrize(
    ("platform", "arch", "triple"),
    [
        ("darwin", "arm64", "aarch64-apple-darwin"),
        ("linux", "amd64", "x86_64-unknown-linux-musl"),
        ("linux", "arm64", "aarch64-unknown-linux-musl"),
    ],
)
def test_platform_triple(
    monkeypatch: pytest.MonkeyPatch, platform: str, arch: str, triple: str
) -> None:
    """Choose the published target for each supported platform."""
    monkeypatch.setattr(lig.sys, "platform", platform)
    monkeypatch.setattr(lig, "arch2", lambda: arch)
    assert lig._platform_triple() == triple


def _write_archive(path: Path, binary_name: str, *, link: bool = False) -> None:
    with tarfile.open(path, "w:gz") as tf:
        info = tarfile.TarInfo(binary_name)
        if link:
            info.type = tarfile.SYMTYPE
            info.linkname = "/bin/sh"
            tf.addfile(info)
        else:
            data = b"example binary"
            info.size = len(data)
            info.mode = 0o755
            tf.addfile(info, io.BytesIO(data))


def test_release_install(monkeypatch: pytest.MonkeyPatch, tmp_path: Path) -> None:
    """Verify the sidecar before installing the binary from its release directory."""
    triple = "aarch64-apple-darwin"
    directory = f"lig-1.3.0-{triple}"
    filename = f"{directory}.tar.gz"
    archive = tmp_path / filename
    _write_archive(archive, f"{directory}/lig")
    checksum = tmp_path / f"{filename}.sha256"
    checksum.write_text(f"{hashlib.sha256(archive.read_bytes()).hexdigest()}  {filename}\n")
    download = Mock(side_effect=[str(archive), str(checksum)])
    fallback = Mock()
    monkeypatch.setattr(lig, "_platform_triple", lambda: triple)
    monkeypatch.setattr(lig, "download_with_mirror", download)
    monkeypatch.setattr(lig._rust_pkg, "main", fallback)

    lig.main(name="lig", version="1.3.0", prefix=str(tmp_path / "prefix"))

    binary = tmp_path / "prefix" / "bin" / "lig"
    assert binary.read_bytes() == b"example binary"
    assert binary.stat().st_mode & 0o111 == 0o111
    assert download.call_args_list[0].args[:3] == (
        f"https://github.com/KevenGoncalves/lig/releases/download/v1.3.0/{filename}",
        "lig",
        filename,
    )
    assert download.call_args_list[1].args[0].endswith(f"{filename}.sha256")
    fallback.assert_not_called()


@pytest.mark.parametrize("sidecar", ["bad", f"{'0' * 64}  other.tar.gz", f"{'0' * 64}  app.tar.gz"])
def test_reject_bad_checksum(tmp_path: Path, sidecar: str) -> None:
    """Reject malformed sidecars, wrong filenames, and mismatched hashes."""
    archive = tmp_path / "app.tar.gz"
    archive.write_bytes(b"archive")
    checksum = tmp_path / "app.tar.gz.sha256"
    checksum.write_text(sidecar)
    with pytest.raises(ValueError, match="SHA-256"):
        lig._verify_archive(str(archive), str(checksum), archive.name)


@pytest.mark.parametrize("member", ["other/lig", "lig-1/lig"])
def test_reject_unexpected_binary(tmp_path: Path, member: str) -> None:
    """Reject a missing binary or a symlink at the expected location."""
    archive = tmp_path / "app.tar.gz"
    _write_archive(archive, member, link=member == "lig-1/lig")
    with pytest.raises(ValueError, match="expected a regular binary"):
        lig._install_archive(str(archive), "lig-1", str(tmp_path / "prefix"))
    assert not (tmp_path / "prefix" / "bin" / "lig").exists()


@pytest.mark.parametrize("missing", [0, 1])
def test_download_failure_uses_source_fallback(
    monkeypatch: pytest.MonkeyPatch, tmp_path: Path, missing: int
) -> None:
    """Use the pinned Cargo tag if either release download is unavailable."""
    entry = import_app_json()["lig"]
    fallback = Mock()
    failure = subprocess.CalledProcessError(22, ["curl"])
    results = [failure] if missing == 0 else ["downloaded", failure]
    monkeypatch.setattr(lig, "_platform_triple", lambda: "aarch64-apple-darwin")
    monkeypatch.setattr(lig, "download_with_mirror", Mock(side_effect=results))
    monkeypatch.setattr(lig, "vendor_config", lambda: None)
    monkeypatch.setattr(lig._rust_pkg, "install_rust_package", fallback)
    lig.main(
        name="lig",
        version=entry["version"],
        prefix=str(tmp_path),
        passthrough_args=install._build_passthrough_args("lig"),
    )
    assert fallback.call_args.kwargs["git_url"] == "https://github.com/KevenGoncalves/lig"
    assert fallback.call_args.kwargs["tag"] == f"v{entry['version']}"


def test_vendor_only_does_not_fall_back_to_public_cargo(
    monkeypatch: pytest.MonkeyPatch, tmp_path: Path
) -> None:
    """A missing vendor artifact cannot trigger public Git or Cargo traffic."""
    monkeypatch.setattr(lig, "_platform_triple", lambda: "aarch64-apple-darwin")
    monkeypatch.setattr(lig, "download_with_mirror", Mock(side_effect=FileNotFoundError("missing")))
    monkeypatch.setattr(lig, "vendor_config", lambda: {"enabled": True})
    monkeypatch.setattr(lig, "vendor_pull_priority", lambda: "vendor_only")
    fallback = Mock()
    monkeypatch.setattr(lig._rust_pkg, "main", fallback)
    with pytest.raises(FileNotFoundError, match="missing"):
        lig.main(name="lig", version="1.3.0", prefix=str(tmp_path))
    fallback.assert_not_called()


def test_checksum_mismatch_does_not_trigger_source_fallback(
    monkeypatch: pytest.MonkeyPatch, tmp_path: Path
) -> None:
    """A downloaded archive that fails verification must not fall back."""
    filename = "lig-1.3.0-aarch64-apple-darwin.tar.gz"
    archive = tmp_path / filename
    archive.write_bytes(b"corrupt")
    checksum = tmp_path / f"{filename}.sha256"
    checksum.write_text(f"{'0' * 64}  {filename}\n")
    monkeypatch.setattr(lig, "_platform_triple", lambda: "aarch64-apple-darwin")
    monkeypatch.setattr(
        lig, "download_with_mirror", Mock(side_effect=[str(archive), str(checksum)])
    )
    fallback = Mock()
    monkeypatch.setattr(lig._rust_pkg, "main", fallback)
    with pytest.raises(ValueError, match="SHA-256 mismatch"):
        lig.main(name="lig", version="1.3.0", prefix=str(tmp_path / "prefix"))
    fallback.assert_not_called()
    assert not (tmp_path / "prefix").exists()


def test_invalid_archive_does_not_trigger_source_fallback(
    monkeypatch: pytest.MonkeyPatch, tmp_path: Path
) -> None:
    """A corrupt download is an integrity error, not a missing release."""
    monkeypatch.setattr(lig, "_platform_triple", lambda: "aarch64-apple-darwin")
    monkeypatch.setattr(
        lig, "download_with_mirror", Mock(side_effect=ValueError("invalid archive"))
    )
    fallback = Mock()
    monkeypatch.setattr(lig._rust_pkg, "main", fallback)
    with pytest.raises(ValueError, match="invalid archive"):
        lig.main(name="lig", version="1.3.0", prefix=str(tmp_path))
    fallback.assert_not_called()
