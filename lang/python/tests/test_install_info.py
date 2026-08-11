"""Install metadata module unit tests."""

import json
from pathlib import Path
from unittest.mock import patch

from koopa.install_info import scrub_install_info


def _write_info(version_dir: Path, environ: dict) -> Path:
    install_dir = version_dir / ".install"
    install_dir.mkdir(parents=True)
    info_file = install_dir / "info.json"
    info_file.write_text(json.dumps({"name": "myapp", "environ": environ}, indent=2) + "\n")
    return info_file


def test_scrub_install_info_removes_non_allowlisted_keys(tmp_path: Path) -> None:
    """A non-allowlisted environ key is removed and reported by name."""
    app_dir = tmp_path / "app"
    info_file = _write_info(
        app_dir / "myapp" / "1.0",
        {"PATH": "/usr/bin", "SOME_PROJECT_TOKEN": "secret-value"},
    )

    with patch("koopa.prefix.app_prefix", return_value=str(app_dir)):
        scrubbed = scrub_install_info(["myapp"])

    assert scrubbed == [(str(info_file), ["SOME_PROJECT_TOKEN"])]
    written = json.loads(info_file.read_text())
    assert written["environ"] == {"PATH": "/usr/bin"}
    assert "secret-value" not in info_file.read_text()


def test_scrub_install_info_dry_run_does_not_write(tmp_path: Path) -> None:
    """dry_run reports what would change without touching the file on disk."""
    app_dir = tmp_path / "app"
    info_file = _write_info(
        app_dir / "myapp" / "1.0",
        {"PATH": "/usr/bin", "SOME_PROJECT_TOKEN": "secret-value"},
    )
    original_text = info_file.read_text()

    with patch("koopa.prefix.app_prefix", return_value=str(app_dir)):
        scrubbed = scrub_install_info(["myapp"], dry_run=True)

    assert scrubbed == [(str(info_file), ["SOME_PROJECT_TOKEN"])]
    assert info_file.read_text() == original_text


def test_scrub_install_info_already_clean_left_untouched(tmp_path: Path) -> None:
    """A file with only allowlisted keys is left byte-identical and not reported."""
    app_dir = tmp_path / "app"
    info_file = _write_info(app_dir / "myapp" / "1.0", {"PATH": "/usr/bin", "CC": "clang"})
    original_text = info_file.read_text()

    with patch("koopa.prefix.app_prefix", return_value=str(app_dir)):
        scrubbed = scrub_install_info(["myapp"])

    assert scrubbed == []
    assert info_file.read_text() == original_text


def test_scrub_install_info_skips_malformed_json(tmp_path: Path) -> None:
    """Malformed info.json is skipped rather than raising."""
    app_dir = tmp_path / "app"
    version_dir = app_dir / "myapp" / "1.0"
    install_dir = version_dir / ".install"
    install_dir.mkdir(parents=True)
    (install_dir / "info.json").write_text("{not valid json")

    with patch("koopa.prefix.app_prefix", return_value=str(app_dir)):
        scrubbed = scrub_install_info(["myapp"])

    assert scrubbed == []


def test_scrub_install_info_defaults_to_every_app(tmp_path: Path) -> None:
    """Passing no names scans every app under app_prefix()."""
    app_dir = tmp_path / "app"
    info_file = _write_info(
        app_dir / "myapp" / "1.0",
        {"PATH": "/usr/bin", "SOME_PROJECT_TOKEN": "secret-value"},
    )

    with patch("koopa.prefix.app_prefix", return_value=str(app_dir)):
        scrubbed = scrub_install_info()

    assert scrubbed == [(str(info_file), ["SOME_PROJECT_TOKEN"])]
