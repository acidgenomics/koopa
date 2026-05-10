"""Disk module unit tests."""

from pathlib import Path

from koopa.disk import (
    df2,
    disk_gb_free,
    disk_gb_total,
    disk_gb_used,
    disk_pct_free,
    disk_pct_used,
    find_large_dirs,
    find_large_files,
)


def test_disk_gb_total_positive() -> None:
    """Test disk_gb_total returns a positive value."""
    assert disk_gb_total("/") > 0


def test_disk_gb_free_positive() -> None:
    """Test disk_gb_free returns a positive value."""
    assert disk_gb_free("/") > 0


def test_disk_gb_used_positive() -> None:
    """Test disk_gb_used returns a positive value."""
    assert disk_gb_used("/") > 0


def test_disk_gb_used_less_than_total() -> None:
    """Test used space is less than total."""
    assert disk_gb_used("/") <= disk_gb_total("/")


def test_disk_pct_free_in_range() -> None:
    """Test disk_pct_free returns value between 0 and 100."""
    pct = disk_pct_free("/")
    assert 0 <= pct <= 100


def test_disk_pct_used_in_range() -> None:
    """Test disk_pct_used returns value between 0 and 100."""
    pct = disk_pct_used("/")
    assert 0 <= pct <= 100


def test_disk_pct_sum() -> None:
    """Test free + used percentages sum to approximately 100."""
    total = disk_pct_free("/") + disk_pct_used("/")
    assert abs(total - 100) < 0.1


def test_df2_keys() -> None:
    """Test df2 returns expected dictionary keys."""
    result = df2("/")
    assert set(result.keys()) == {"path", "total_gb", "used_gb", "free_gb", "pct_used"}


def test_df2_path() -> None:
    """Test df2 includes correct path."""
    result = df2("/tmp")
    assert result["path"] == "/tmp"


def test_df2_pct_format() -> None:
    """Test df2 pct_used ends with percent sign."""
    result = df2("/")
    assert result["pct_used"].endswith("%")


def test_find_large_files_empty(tmp_path: Path) -> None:
    """Test find_large_files returns empty for small files."""
    (tmp_path / "small.txt").write_text("hello")
    result = find_large_files(str(tmp_path), min_size_mb=1)
    assert result == []


def test_find_large_files_finds_big(tmp_path: Path) -> None:
    """Test find_large_files finds files above threshold."""
    big = tmp_path / "big.bin"
    big.write_bytes(b"\x00" * (2 * 1024 * 1024))
    result = find_large_files(str(tmp_path), min_size_mb=1)
    assert len(result) == 1
    assert result[0][0] == str(big)
    assert result[0][1] >= 2.0


def test_find_large_files_max_results(tmp_path: Path) -> None:
    """Test find_large_files respects max_results."""
    for i in range(5):
        (tmp_path / f"big{i}.bin").write_bytes(b"\x00" * (2 * 1024 * 1024))
    result = find_large_files(str(tmp_path), min_size_mb=1, max_results=3)
    assert len(result) == 3


def test_find_large_dirs_empty(tmp_path: Path) -> None:
    """Test find_large_dirs returns empty for small directories."""
    (tmp_path / "sub").mkdir()
    (tmp_path / "sub" / "tiny.txt").write_text("x")
    result = find_large_dirs(str(tmp_path), min_size_mb=100)
    assert result == []


def test_find_large_dirs_finds_big(tmp_path: Path) -> None:
    """Test find_large_dirs finds directories above threshold."""
    sub = tmp_path / "heavy"
    sub.mkdir()
    (sub / "big.bin").write_bytes(b"\x00" * (2 * 1024 * 1024))
    result = find_large_dirs(str(tmp_path), min_size_mb=1)
    paths = [r[0] for r in result]
    assert str(sub) in paths
