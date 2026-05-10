"""Download module unit tests."""

from koopa.download import _derive_filename


def test_derive_filename_simple_url() -> None:
    """Test filename derivation from simple URL."""
    assert _derive_filename("https://example.com/foo.tar.gz") == "foo.tar.gz"


def test_derive_filename_download_path() -> None:
    """Test filename derivation falls back to parent dir basename."""
    result = _derive_filename("https://example.com/releases/v1.0/download")
    assert result == "v1.0"


def test_derive_filename_no_path() -> None:
    """Test filename derivation with bare domain."""
    assert _derive_filename("https://example.com/") == "download"


def test_derive_filename_query_params() -> None:
    """Test filename derivation ignores query parameters."""
    result = _derive_filename("https://example.com/file.zip?token=abc")
    assert result == "file.zip"
