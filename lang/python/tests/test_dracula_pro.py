"""Dracula Pro theme bundle unit tests."""

import zipfile
from pathlib import Path

import pytest
from koopa.dracula_pro import (
    CHANGELOG_RSS_URL,
    MIN_SUPPORTED_VERSION,
    _mentioned_version,
    check,
    dracula_pro_dir,
    install,
    installed_version,
    is_outdated_layout,
    latest_version,
    version_from_zip_filename,
)

_SAMPLE_FEED = """<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0">
  <channel>
    <item>
      <title><![CDATA[Visual Studio Code v2.2.4 fixes]]></title>
      <description><![CDATA[Fixes for the Visual Studio Code extension only.]]></description>
    </item>
    <item>
      <title><![CDATA[Firefox and Notepad++]]></title>
      <description><![CDATA[Now available in package v2.2.3.]]></description>
    </item>
    <item>
      <title><![CDATA[Raycast fix]]></title>
      <description><![CDATA[Released version 2.1 with additional improvements.]]></description>
    </item>
  </channel>
</rss>
"""


def _make_zip(tmp_path: Path, name: str, files: dict[str, str]) -> Path:
    zip_path = tmp_path / name
    with zipfile.ZipFile(zip_path, "w") as zf:
        for arcname, content in files.items():
            zf.writestr(arcname, content)
    return zip_path


def test_version_from_zip_filename() -> None:
    """Extracts a semver from the standard Gumroad download filename."""
    assert version_from_zip_filename("dracula-pro-v2.2.3.zip") == "2.2.3"
    assert version_from_zip_filename("/tmp/dracula-pro-v2.2.zip") == "2.2"


def test_version_from_zip_filename_no_match() -> None:
    """Returns None for a filename with no version."""
    assert version_from_zip_filename("dracula-pro.zip") is None


def test_mentioned_version_v_prefix() -> None:
    """Matches a 'vX.Y.Z' mention."""
    assert _mentioned_version("now available in package v2.2.3.") == "2.2.3"


def test_mentioned_version_word_form() -> None:
    """Matches a 'version X.Y' mention."""
    assert _mentioned_version("released version 2.1 with fixes.") == "2.1"


def test_mentioned_version_none() -> None:
    """Returns None when no version is mentioned."""
    assert _mentioned_version("Important fixes, no version bump here.") is None


def test_installed_version_missing(tmp_path: Path, monkeypatch: pytest.MonkeyPatch) -> None:
    """Returns None when Dracula Pro is not installed."""
    monkeypatch.setenv("XDG_DATA_HOME", str(tmp_path))
    assert installed_version() is None


def test_dracula_pro_dir(tmp_path: Path, monkeypatch: pytest.MonkeyPatch) -> None:
    """Resolves under XDG_DATA_HOME."""
    monkeypatch.setenv("XDG_DATA_HOME", str(tmp_path))
    assert dracula_pro_dir() == str(tmp_path / "dracula-pro")


def test_install_missing_zip(tmp_path: Path, monkeypatch: pytest.MonkeyPatch) -> None:
    """Raises FileNotFoundError for a nonexistent zip."""
    monkeypatch.setenv("XDG_DATA_HOME", str(tmp_path))
    with pytest.raises(FileNotFoundError):
        install(str(tmp_path / "missing.zip"), configure=False)


def test_install_writes_version_marker_and_files(
    tmp_path: Path, monkeypatch: pytest.MonkeyPatch
) -> None:
    """Extracts bundle files and records the parsed version."""
    monkeypatch.setenv("XDG_DATA_HOME", str(tmp_path))
    zip_path = _make_zip(
        tmp_path,
        "dracula-pro-v2.2.3.zip",
        {"readme.md": "Dracula Pro", "themes/ghostty/pro": "palette"},
    )

    version = install(str(zip_path), configure=False)

    assert version == "2.2.3"
    dest = dracula_pro_dir()
    assert (Path(dest) / "readme.md").read_text() == "Dracula Pro"
    assert (Path(dest) / "themes" / "ghostty" / "pro").is_file()
    assert installed_version() == "2.2.3"


def test_install_backs_up_and_replaces_existing(
    tmp_path: Path, monkeypatch: pytest.MonkeyPatch
) -> None:
    """A stale file from an old install does not survive a fresh install."""
    monkeypatch.setenv("XDG_DATA_HOME", str(tmp_path))
    old_zip = _make_zip(
        tmp_path, "dracula-pro-v2.2.2.zip", {"readme.md": "old", "stale.txt": "gone next release"}
    )
    install(str(old_zip), configure=False)
    assert (Path(dracula_pro_dir()) / "stale.txt").is_file()

    new_zip = _make_zip(tmp_path, "dracula-pro-v2.2.3.zip", {"readme.md": "new"})
    version = install(str(new_zip), configure=False)

    assert version == "2.2.3"
    dest = Path(dracula_pro_dir())
    assert (dest / "readme.md").read_text() == "new"
    assert not (dest / "stale.txt").exists()
    backups = list(tmp_path.glob("dracula-pro.bak-*"))
    assert len(backups) == 1
    assert (backups[0] / "stale.txt").is_file()


def test_install_no_version_in_filename_warns(
    tmp_path: Path, monkeypatch: pytest.MonkeyPatch, capsys: pytest.CaptureFixture[str]
) -> None:
    """Installs without a marker and warns when the filename has no version."""
    monkeypatch.setenv("XDG_DATA_HOME", str(tmp_path))
    zip_path = _make_zip(tmp_path, "dracula-pro.zip", {"readme.md": "x"})

    version = install(str(zip_path), configure=False)

    assert version is None
    assert installed_version() is None
    assert "Could not parse a version" in capsys.readouterr().err


def test_is_outdated_layout_not_installed(tmp_path: Path, monkeypatch: pytest.MonkeyPatch) -> None:
    """Returns False when Dracula Pro is not installed."""
    monkeypatch.setenv("XDG_DATA_HOME", str(tmp_path))
    assert is_outdated_layout() is False


def test_is_outdated_layout_old_version(tmp_path: Path, monkeypatch: pytest.MonkeyPatch) -> None:
    """Returns True for an installed version older than MIN_SUPPORTED_VERSION."""
    monkeypatch.setenv("XDG_DATA_HOME", str(tmp_path))
    zip_path = _make_zip(tmp_path, "dracula-pro-v2.2.2.zip", {"readme.md": "x"})
    install(str(zip_path), configure=False)
    assert is_outdated_layout() is True


def test_is_outdated_layout_current_version(
    tmp_path: Path, monkeypatch: pytest.MonkeyPatch
) -> None:
    """Returns False for an installed version at MIN_SUPPORTED_VERSION."""
    monkeypatch.setenv("XDG_DATA_HOME", str(tmp_path))
    zip_path = _make_zip(tmp_path, f"dracula-pro-v{MIN_SUPPORTED_VERSION}.zip", {"readme.md": "x"})
    install(str(zip_path), configure=False)
    assert is_outdated_layout() is False


def test_latest_version_skips_entries_without_a_version(monkeypatch: pytest.MonkeyPatch) -> None:
    """Returns the first version mentioned, walking past entries with none."""
    requested_urls = []

    def fake_http_get_text(url: str, **_kwargs: object) -> str:
        requested_urls.append(url)
        return _SAMPLE_FEED

    monkeypatch.setattr("koopa.version_check._http_get_text", fake_http_get_text)

    assert latest_version() == "2.2.3"
    assert requested_urls == [CHANGELOG_RSS_URL]


def test_latest_version_raises_when_feed_has_no_version(monkeypatch: pytest.MonkeyPatch) -> None:
    """Raises ValueError when no feed entry mentions a version."""
    monkeypatch.setattr(
        "koopa.version_check._http_get_text",
        lambda _url, **_kwargs: "<rss><channel><item><title>No version here</title></item>"
        "</channel></rss>",
    )
    with pytest.raises(ValueError, match="No version number found"):
        latest_version()


def test_check_up_to_date(
    tmp_path: Path, monkeypatch: pytest.MonkeyPatch, capsys: pytest.CaptureFixture[str]
) -> None:
    """Prints a success message when installed matches latest."""
    monkeypatch.setenv("XDG_DATA_HOME", str(tmp_path))
    zip_path = _make_zip(tmp_path, "dracula-pro-v2.2.3.zip", {"readme.md": "x"})
    install(str(zip_path), configure=False)
    monkeypatch.setattr("koopa.dracula_pro.latest_version", lambda: "2.2.3")

    check()

    assert "up to date" in capsys.readouterr().err


def test_check_outdated_warns(
    tmp_path: Path, monkeypatch: pytest.MonkeyPatch, capsys: pytest.CaptureFixture[str]
) -> None:
    """Warns and names the newer release when installed lags behind latest."""
    monkeypatch.setenv("XDG_DATA_HOME", str(tmp_path))
    zip_path = _make_zip(tmp_path, "dracula-pro-v2.2.2.zip", {"readme.md": "x"})
    install(str(zip_path), configure=False)
    monkeypatch.setattr("koopa.dracula_pro.latest_version", lambda: "2.2.3")

    check()

    err = capsys.readouterr().err
    assert "2.2.2" in err
    assert "2.2.3" in err


def test_check_not_installed_warns(
    tmp_path: Path, monkeypatch: pytest.MonkeyPatch, capsys: pytest.CaptureFixture[str]
) -> None:
    """Warns when no version is on record."""
    monkeypatch.setenv("XDG_DATA_HOME", str(tmp_path))
    monkeypatch.setattr("koopa.dracula_pro.latest_version", lambda: "2.2.3")

    check()

    assert "No installed" in capsys.readouterr().err
