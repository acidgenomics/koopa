"""Lig patched source installer tests."""

import hashlib
import io
import subprocess
import tarfile
from pathlib import Path
from unittest.mock import Mock

import pytest
from koopa.installers import lig


def _source_archive(path: Path) -> None:
    with tarfile.open(path, "w:gz") as tf:
        info = tarfile.TarInfo("lig-1.3.0/Cargo.toml")
        data = b"[package]\nname = 'lig'\n"
        info.size = len(data)
        tf.addfile(info, io.BytesIO(data))


def test_install_applies_patch_before_build(
    monkeypatch: pytest.MonkeyPatch, tmp_path: Path
) -> None:
    """Verify the pinned source, apply the patch, then install from that source."""
    archive = tmp_path / "source.tar.gz"
    _source_archive(archive)
    monkeypatch.setattr(lig, "_SOURCE_SHA256", hashlib.sha256(archive.read_bytes()).hexdigest())
    monkeypatch.setattr(lig, "vendor_config", lambda: None)
    monkeypatch.setattr(lig.shutil, "which", lambda _: "/bin/cargo")
    download = Mock(return_value=str(archive))
    run = Mock()
    monkeypatch.setattr(lig, "download_with_mirror", download)
    monkeypatch.setattr(lig.subprocess, "run", run)

    lig.main(name="lig", version="1.3.0", prefix=str(tmp_path / "prefix"))

    assert download.call_args.args[:3] == (
        "https://github.com/KevenGoncalves/lig/archive/refs/tags/v1.3.0.tar.gz",
        "lig",
        "lig-1.3.0.tar.gz",
    )
    patch_call, cargo_call = run.call_args_list
    assert patch_call.args[0][:4] == ["patch", "-p1", "-F", "0"]
    assert patch_call.args[0][-1].endswith("etc/koopa/lig/1.3.0-theme-reload.patch")
    assert cargo_call.args[0][:3] == ["/bin/cargo", "install", "--locked"]
    assert cargo_call.args[0][3:5] == ["--path", str(patch_call.kwargs["cwd"])]
    assert cargo_call.args[0][-2:] == ["--root", str(tmp_path / "prefix")]
    assert cargo_call.kwargs["env"]["CARGO_HOME"].endswith("/cargo")
    assert patch_call.kwargs["check"] is True
    assert cargo_call.kwargs["check"] is True


def test_unknown_version_fails_closed(tmp_path: Path) -> None:
    """Never install an unpatched newer version."""
    with pytest.raises(ValueError, match=r"requires version 1\.3\.0"):
        lig.main(name="lig", version="1.4.0", prefix=str(tmp_path))


def test_vendor_only_does_not_contact_cargo(
    monkeypatch: pytest.MonkeyPatch, tmp_path: Path
) -> None:
    """A source build must not bypass vendor-only network policy."""
    monkeypatch.setattr(lig, "vendor_config", lambda: {"enabled": True})
    monkeypatch.setattr(lig, "vendor_pull_priority", lambda: "vendor_only")
    download = Mock()
    monkeypatch.setattr(lig, "download_with_mirror", download)
    with pytest.raises(RuntimeError, match="Cargo registry access"):
        lig.main(name="lig", version="1.3.0", prefix=str(tmp_path))
    download.assert_not_called()


def test_source_digest_mismatch_fails_before_build(
    monkeypatch: pytest.MonkeyPatch, tmp_path: Path
) -> None:
    """Reject altered source archives rather than building them."""
    archive = tmp_path / "source.tar.gz"
    _source_archive(archive)
    monkeypatch.setattr(lig, "vendor_config", lambda: None)
    monkeypatch.setattr(lig.shutil, "which", lambda _: "/bin/cargo")
    monkeypatch.setattr(lig, "download_with_mirror", Mock(return_value=str(archive)))
    run = Mock()
    monkeypatch.setattr(lig.subprocess, "run", run)
    with pytest.raises(ValueError, match="SHA-256 mismatch"):
        lig.main(name="lig", version="1.3.0", prefix=str(tmp_path))
    run.assert_not_called()


def test_patch_failure_does_not_install(monkeypatch: pytest.MonkeyPatch, tmp_path: Path) -> None:
    """Never fall back to an unpatched build if the patch fails."""
    archive = tmp_path / "source.tar.gz"
    _source_archive(archive)
    monkeypatch.setattr(lig, "_SOURCE_SHA256", hashlib.sha256(archive.read_bytes()).hexdigest())
    monkeypatch.setattr(lig, "vendor_config", lambda: None)
    monkeypatch.setattr(lig.shutil, "which", lambda _: "/bin/cargo")
    monkeypatch.setattr(lig, "download_with_mirror", Mock(return_value=str(archive)))
    run = Mock(side_effect=subprocess.CalledProcessError(1, ["patch"]))
    monkeypatch.setattr(lig.subprocess, "run", run)
    with pytest.raises(subprocess.CalledProcessError):
        lig.main(name="lig", version="1.3.0", prefix=str(tmp_path))
    assert run.call_count == 1
