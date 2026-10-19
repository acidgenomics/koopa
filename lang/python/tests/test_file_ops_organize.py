"""Tests for koopa.file_ops.organize_screenshots."""

import os
from datetime import datetime
from pathlib import Path

import pytest
from koopa.file_ops import organize_screenshots


def _make_png(path: Path, when: datetime) -> None:
    path.write_bytes(b"png")
    stamp = when.timestamp()
    os.utime(path, (stamp, stamp))


def test_organize_screenshots_moves_into_local_dated_dirs(tmp_path: Path) -> None:
    """Test kebab-case rename and local-time dated destination."""
    pytest.importorskip("syntactic")
    _make_png(tmp_path / "Screenshot 2026-10-18 at 9.15.00 PM.png", datetime(2026, 10, 18, 21, 15))
    result = organize_screenshots(str(tmp_path), quiet=True)
    assert len(result) == 1
    dest = Path(result[0])
    assert dest.parent == tmp_path / "2026" / "10" / "18"
    assert dest.name == dest.name.lower()
    assert " " not in dest.name
    assert dest.is_file()
    assert list(tmp_path.glob("*.png")) == []


def test_organize_screenshots_dry_run_changes_nothing(tmp_path: Path) -> None:
    """Test that dry run leaves files untouched."""
    pytest.importorskip("syntactic")
    src = tmp_path / "My Shot.png"
    _make_png(src, datetime(2026, 1, 2, 12, 0))
    organize_screenshots(str(tmp_path), dry_run=True, quiet=True)
    assert src.is_file()
    assert [p.name for p in tmp_path.iterdir()] == ["My Shot.png"]


def test_organize_screenshots_collision_raises(tmp_path: Path) -> None:
    """Test that an existing destination stops the run."""
    when = datetime(2026, 3, 4, 12, 0)
    existing = tmp_path / "2026" / "03" / "04"
    existing.mkdir(parents=True)
    (existing / "my-shot.png").write_bytes(b"old")
    _make_png(tmp_path / "My Shot.png", when)
    with pytest.raises(SystemExit):
        organize_screenshots(str(tmp_path), quiet=True)
    assert (existing / "my-shot.png").read_bytes() == b"old"


def test_organize_screenshots_missing_directory(tmp_path: Path) -> None:
    """Test that a missing directory raises SystemExit."""
    with pytest.raises(SystemExit):
        organize_screenshots(str(tmp_path / "nope"))
