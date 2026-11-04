"""Tests for koopa.file_ops.organize_screenshots."""

import os
from datetime import datetime
from pathlib import Path

import pytest
from koopa.file_ops import organize_screenshots


def _make_file(path: Path, when: datetime) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_bytes(b"data")
    stamp = when.timestamp()
    os.utime(path, (stamp, stamp))


def _organize_one(tmp_path: Path, name: str) -> Path:
    """Organize one file named ``name`` and return its new path."""
    _make_file(tmp_path / name, datetime(2000, 1, 1, 0, 0))
    result = organize_screenshots(str(tmp_path), quiet=True)
    assert len(result) == 1
    return Path(result[0])


@pytest.mark.parametrize(
    ("name", "expected_hour"),
    [
        ("Screenshot 2026-10-01 at 12.00.00 AM.png", "00"),
        ("Screenshot 2026-10-01 at 12.30.00 PM.png", "12"),
        ("Screenshot 2026-10-01 at 1.05.00 PM.png", "13"),
        ("Screenshot 2026-10-01 at 11.59.59 PM.png", "23"),
        ("Screenshot 2026-10-01 at 7.17.11 AM.png", "07"),
        ("Screenshot 2026-10-01 at 11.00.00 AM.png", "11"),
    ],
)
def test_macos_name_converts_to_zero_padded_24_hour(
    tmp_path: Path, name: str, expected_hour: str
) -> None:
    """Test the 12-hour to 24-hour conversion and zero padding."""
    dest = _organize_one(tmp_path, name)
    assert dest.parent == tmp_path / "2026" / "10" / "01"
    assert dest.name.startswith("screenshot-2026-10-01-")
    assert dest.name.split("-")[4] == expected_hour


def test_macos_name_with_narrow_no_break_space(tmp_path: Path) -> None:
    """Test a macOS name that puts U+202F before AM or PM."""
    dest = _organize_one(tmp_path, "Screenshot 2026-10-01 at 7.17.11 PM.png")
    assert dest.name == "screenshot-2026-10-01-19-17-11.png"


def test_macos_duplicate_marker_is_dropped(tmp_path: Path) -> None:
    """Test that macOS's ' (2)' duplicate marker does not survive the rename."""
    dest = _organize_one(tmp_path, "Screenshot 2026-10-01 at 7.17.11 AM (2).png")
    assert dest.name == "screenshot-2026-10-01-07-17-11.png"


def test_legacy_kebab_name_converts(tmp_path: Path) -> None:
    """Test the earlier kebab-case name with a duplicate suffix."""
    dest = _organize_one(tmp_path, "screenshot-2026-10-01-at-9-15-00-pm-1-2.png")
    assert dest.name == "screenshot-2026-10-01-21-15-00.png"


def test_2024_name_stays_24_hour(tmp_path: Path) -> None:
    """Test the 2024 six-digit time form."""
    dest = _organize_one(tmp_path, "screenshot-2024-06-10-102152.png")
    assert dest.parent == tmp_path / "2024" / "06" / "10"
    assert dest.name == "screenshot-2024-06-10-10-21-52.png"


def test_screen_recording_converts(tmp_path: Path) -> None:
    """Test that a .mov recording uses the screen-recording prefix."""
    dest = _organize_one(tmp_path, "Screen Recording 2026-10-01 at 1.05.00 PM.mov")
    assert dest.name == "screen-recording-2026-10-01-13-05-00.mov"


def test_unrecognized_name_stays_in_place(tmp_path: Path) -> None:
    """Test that a name that matches no form is left alone."""
    src = tmp_path / "My Shot.png"
    _make_file(src, datetime(2026, 1, 2, 12, 0))
    result = organize_screenshots(str(tmp_path), quiet=True)
    assert result == []
    assert src.is_file()


def test_invalid_hour_stays_in_place(tmp_path: Path) -> None:
    """Test that hour 13 with AM or PM is rejected, not converted."""
    src = tmp_path / "Screenshot 2026-10-01 at 13.00.00 PM.png"
    _make_file(src, datetime(2026, 10, 1, 13, 0))
    assert organize_screenshots(str(tmp_path), quiet=True) == []
    assert src.is_file()


def test_organize_screenshots_dry_run_changes_nothing(tmp_path: Path) -> None:
    """Test that dry run leaves files untouched."""
    src = tmp_path / "Screenshot 2026-10-01 at 7.17.11 AM.png"
    _make_file(src, datetime(2026, 10, 1, 7, 17))
    organize_screenshots(str(tmp_path), dry_run=True, quiet=True)
    assert src.is_file()
    assert [p.name for p in tmp_path.iterdir()] == [src.name]


def test_collision_gets_suffix_and_overwrites_nothing(tmp_path: Path) -> None:
    """Test that a name collision adds a suffix instead of overwriting."""
    existing = tmp_path / "2026" / "10" / "01"
    existing.mkdir(parents=True)
    (existing / "screenshot-2026-10-01-07-17-11.png").write_bytes(b"old")
    _make_file(
        tmp_path / "Screenshot 2026-10-01 at 7.17.11 AM.png",
        datetime(2026, 10, 1, 7, 17),
    )
    result = organize_screenshots(str(tmp_path), quiet=True)
    assert [Path(p).name for p in result] == ["screenshot-2026-10-01-07-17-11-1.png"]
    assert (existing / "screenshot-2026-10-01-07-17-11.png").read_bytes() == b"old"


def test_recursive_rehomes_file_to_its_name_date(tmp_path: Path) -> None:
    """Test that recursive mode moves a file to the folder its name gives."""
    wrong = tmp_path / "2026" / "05" / "20" / "screenshot-2026-05-19-at-8-38-45-pm.png"
    _make_file(wrong, datetime(2026, 5, 20, 0, 30))
    result = organize_screenshots(str(tmp_path), quiet=True, recursive=True)
    assert len(result) == 1
    assert Path(result[0]) == tmp_path / "2026" / "05" / "19" / "screenshot-2026-05-19-20-38-45.png"
    assert not wrong.exists()


def test_top_level_only_by_default(tmp_path: Path) -> None:
    """Test that files inside dated folders are untouched without recursive."""
    nested = tmp_path / "2026" / "05" / "19" / "screenshot-2026-05-19-at-8-38-45-pm.png"
    _make_file(nested, datetime(2026, 5, 19, 20, 38))
    assert organize_screenshots(str(tmp_path), quiet=True) == []
    assert nested.is_file()


def test_missing_directory_raises(tmp_path: Path) -> None:
    """Test that a missing directory raises SystemExit."""
    with pytest.raises(SystemExit):
        organize_screenshots(str(tmp_path / "nope"))
