"""Version module unit tests."""

from koopa.version import (
    extract_version,
    major_minor_patch_version,
    major_minor_version,
    major_version,
    sanitize_version,
    version_pattern,
)


def test_extract_version_simple() -> None:
    """Test extraction of simple version string."""
    assert extract_version("git version 2.40.1") == "2.40.1"


def test_extract_version_with_prefix() -> None:
    """Test extraction from string with prefix text."""
    assert extract_version("Python 3.13.2") == "3.13.2"


def test_extract_version_two_part() -> None:
    """Test extraction of major.minor version."""
    assert extract_version("ruby 4.0") == "4.0"


def test_extract_version_with_suffix() -> None:
    """Test extraction of version with pre-release suffix."""
    assert extract_version("v1.2.3-beta+build") == "1.2.3-beta+build"


def test_extract_version_no_match() -> None:
    """Test extraction returns empty string when no version found."""
    assert extract_version("no version here") == ""


def test_extract_version_embedded() -> None:
    """Test extraction from URL-like string."""
    assert extract_version("download/v3.14.0/package.tar.gz") == "3.14.0"


def test_major_version() -> None:
    """Test major version extraction."""
    assert major_version("3.13.2") == "3"


def test_major_version_single() -> None:
    """Test major version from single number."""
    assert major_version("7") == "7"


def test_major_minor_version() -> None:
    """Test major.minor version extraction."""
    assert major_minor_version("3.13.2") == "3.13"


def test_major_minor_version_two_part() -> None:
    """Test major.minor from two-part version returns as-is."""
    assert major_minor_version("4.0") == "4.0"


def test_major_minor_version_single() -> None:
    """Test major.minor from single number returns as-is."""
    assert major_minor_version("7") == "7"


def test_major_minor_patch_version() -> None:
    """Test major.minor.patch extraction."""
    assert major_minor_patch_version("3.13.2.1") == "3.13.2"


def test_major_minor_patch_version_exact() -> None:
    """Test major.minor.patch from exact three-part returns as-is."""
    assert major_minor_patch_version("1.2.3") == "1.2.3"


def test_major_minor_patch_version_short() -> None:
    """Test major.minor.patch from short version returns as-is."""
    assert major_minor_patch_version("1.2") == "1.2"


def test_sanitize_version_strips_v() -> None:
    """Test sanitize_version strips leading 'v'."""
    assert sanitize_version("v1.2.3") == "1.2.3"


def test_sanitize_version_strips_capital_v() -> None:
    """Test sanitize_version strips leading 'V'."""
    assert sanitize_version("V2.0.0") == "2.0.0"


def test_sanitize_version_strips_whitespace() -> None:
    """Test sanitize_version strips surrounding whitespace."""
    assert sanitize_version("  1.0.0  ") == "1.0.0"


def test_sanitize_version_preserves_letter_suffix() -> None:
    """Test sanitize_version preserves trailing letter (e.g., 1.2.3a)."""
    assert sanitize_version("v1.2.3a") == "1.2.3a"


def test_sanitize_version_plain() -> None:
    """Test sanitize_version with no prefix."""
    assert sanitize_version("10.2.1") == "10.2.1"


def test_sanitize_version_preserves_beta_marker() -> None:
    """Test sanitize_version preserves an explicit pre-release marker and its digits."""
    assert sanitize_version("3.15.0beta2") == "3.15.0beta2"


def test_sanitize_version_preserves_rc_marker() -> None:
    """Test sanitize_version preserves an 'rc' pre-release marker."""
    assert sanitize_version("3.14.0rc1") == "3.14.0rc1"


def test_sanitize_version_preserves_alpha_marker() -> None:
    """Test sanitize_version preserves an 'alpha' pre-release marker."""
    assert sanitize_version("1.2.0alpha") == "1.2.0alpha"


def test_sanitize_version_preserves_dotted_beta_marker() -> None:
    """Test sanitize_version preserves a dot-separated pre-release marker."""
    assert sanitize_version("1.92.0.beta1") == "1.92.0.beta1"


def test_sanitize_version_preserves_hyphenated_rc_marker() -> None:
    """Test sanitize_version preserves a hyphen-separated pre-release marker."""
    assert sanitize_version("1.2.3-rc2") == "1.2.3-rc2"


def test_sanitize_version_preserves_dev_marker() -> None:
    """Test sanitize_version preserves a 'dev' pre-release marker with digits."""
    assert sanitize_version("2.0.0.dev4") == "2.0.0.dev4"


def test_sanitize_version_preserves_letter_suffix_no_marker() -> None:
    """Test sanitize_version still preserves a bare trailing letter (no marker word)."""
    assert sanitize_version("1.1.1w") == "1.1.1w"


def test_version_pattern_matches() -> None:
    """Test version_pattern produces a valid regex."""
    import re

    pat = re.compile(version_pattern())
    assert pat.search("version 1.2.3") is not None
    assert pat.search("no version") is None
