"""Archive module unit tests."""

import gzip
import tarfile
import zipfile
from pathlib import Path

from koopa.archive import (
    compress,
    decompress,
    extract,
    is_valid_archive,
    tar_multiple_dirs,
)


def test_is_valid_archive_gzip(tmp_path: Path) -> None:
    """Test is_valid_archive detects gzip files."""
    gz = tmp_path / "test.gz"
    with gzip.open(str(gz), "wb") as f:
        f.write(b"hello")
    assert is_valid_archive(str(gz)) is True


def test_is_valid_archive_bz2(tmp_path: Path) -> None:
    """Test is_valid_archive detects bz2 files."""
    import bz2

    bz = tmp_path / "test.bz2"
    with bz2.open(str(bz), "wb") as f:
        f.write(b"hello")
    assert is_valid_archive(str(bz)) is True


def test_is_valid_archive_plain_text(tmp_path: Path) -> None:
    """Test is_valid_archive rejects plain text."""
    txt = tmp_path / "plain.txt"
    txt.write_text("not an archive")
    assert is_valid_archive(str(txt)) is False


def test_is_valid_archive_nonexistent() -> None:
    """Test is_valid_archive returns False for missing files."""
    assert is_valid_archive("/nonexistent/file.gz") is False


def test_is_valid_archive_empty(tmp_path: Path) -> None:
    """Test is_valid_archive rejects empty files."""
    empty = tmp_path / "empty"
    empty.write_bytes(b"")
    assert is_valid_archive(str(empty)) is False


def test_extract_tar_gz(tmp_path: Path) -> None:
    """Test extracting a tar.gz archive."""
    src_dir = tmp_path / "src"
    src_dir.mkdir()
    (src_dir / "hello.txt").write_text("world")
    archive = tmp_path / "test.tar.gz"
    with tarfile.open(str(archive), "w:gz") as tf:
        tf.add(str(src_dir), arcname="src")
    out = tmp_path / "out"
    extract(str(archive), str(out))
    assert (out / "hello.txt").read_text() == "world"


def test_extract_zip(tmp_path: Path) -> None:
    """Test extracting a zip archive."""
    archive = tmp_path / "test.zip"
    with zipfile.ZipFile(str(archive), "w") as zf:
        zf.writestr("data/file.txt", "content")
    out = tmp_path / "out"
    extract(str(archive), str(out))
    assert (out / "file.txt").read_text() == "content"


def test_extract_default_output_dir(tmp_path: Path) -> None:
    """Test extract uses basename as output dir when none specified."""
    src_dir = tmp_path / "project"
    src_dir.mkdir()
    (src_dir / "readme.txt").write_text("hi")
    archive = tmp_path / "project.tar.gz"
    with tarfile.open(str(archive), "w:gz") as tf:
        tf.add(str(src_dir), arcname="project")
    extract(str(archive))
    assert (tmp_path / "project" / "readme.txt").read_text() == "hi"


def test_decompress_gz(tmp_path: Path) -> None:
    """Test decompressing a gzip file."""
    original = tmp_path / "data.txt"
    original.write_text("decompressed content")
    gz = tmp_path / "data.txt.gz"
    with gzip.open(str(gz), "wb") as f:
        f.write(b"decompressed content")
    result = decompress(str(gz))
    assert Path(result).read_text() == "decompressed content"


def test_decompress_bz2(tmp_path: Path) -> None:
    """Test decompressing a bz2 file."""
    import bz2

    bz = tmp_path / "data.txt.bz2"
    with bz2.open(str(bz), "wb") as f:
        f.write(b"bz2 content")
    result = decompress(str(bz))
    assert Path(result).read_text() == "bz2 content"


def test_tar_multiple_dirs(tmp_path: Path) -> None:
    """Test creating tar archives for multiple directories."""
    for name in ("alpha", "beta"):
        d = tmp_path / name
        d.mkdir()
        (d / "file.txt").write_text(name)
    output = tmp_path / "archives"
    result = tar_multiple_dirs(
        [str(tmp_path / "alpha"), str(tmp_path / "beta")],
        output_dir=str(output),
    )
    assert len(result) == 2
    assert all(r.endswith(".tar.gz") for r in result)
    for r in result:
        assert tarfile.is_tarfile(r)


def test_compress_file_gzip(tmp_path: Path) -> None:
    """Test compressing a file with gzip."""
    src = tmp_path / "data.txt"
    src.write_text("compress me")
    result = compress(str(src), method="gzip")
    assert result.endswith(".gz")
    with gzip.open(result, "rb") as f:
        assert f.read() == b"compress me"


def test_compress_file_bzip2(tmp_path: Path) -> None:
    """Test compressing a file with bzip2."""
    import bz2

    src = tmp_path / "data.txt"
    src.write_text("bz2 this")
    result = compress(str(src), method="bzip2")
    assert result.endswith(".bz2")
    with bz2.open(result, "rb") as f:
        assert f.read() == b"bz2 this"


def test_compress_directory(tmp_path: Path) -> None:
    """Test compressing a directory creates a tar.gz."""
    src = tmp_path / "mydir"
    src.mkdir()
    (src / "file.txt").write_text("inside")
    result = compress(str(src))
    assert result.endswith(".tar.gz")
    assert tarfile.is_tarfile(result)
