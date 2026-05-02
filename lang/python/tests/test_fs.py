"""File system module unit tests."""

from pathlib import Path

from koopa.fs import list_subdirs


def test_list_subdirs_non_recursive(tmp_path: Path) -> None:
    """Test list_subdirs finds immediate subdirectories."""
    (tmp_path / "a").mkdir()
    (tmp_path / "b").mkdir()
    (tmp_path / "file.txt").write_text("")
    result = list_subdirs(str(tmp_path))
    basenames = sorted(Path(p).name for p in result)
    assert basenames == ["a", "b"]


def test_list_subdirs_recursive(tmp_path: Path) -> None:
    """Test list_subdirs finds nested subdirectories."""
    (tmp_path / "a").mkdir()
    (tmp_path / "a" / "nested").mkdir()
    result = list_subdirs(str(tmp_path), recursive=True)
    basenames = sorted(Path(p).name for p in result)
    assert "nested" in basenames


def test_list_subdirs_sort(tmp_path: Path) -> None:
    """Test list_subdirs returns sorted output."""
    (tmp_path / "z").mkdir()
    (tmp_path / "a").mkdir()
    (tmp_path / "m").mkdir()
    result = list_subdirs(str(tmp_path), sort=True, basename_only=True)
    assert result == ["a", "m", "z"]


def test_list_subdirs_basename_only(tmp_path: Path) -> None:
    """Test list_subdirs returns only basenames."""
    (tmp_path / "subdir").mkdir()
    result = list_subdirs(str(tmp_path), basename_only=True)
    assert result == ["subdir"]


def test_list_subdirs_empty(tmp_path: Path) -> None:
    """Test list_subdirs returns empty for empty directory."""
    assert list_subdirs(str(tmp_path)) == []
