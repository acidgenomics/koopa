"""R package repository management unit tests."""

from koopa.cran import _superseded_filenames


def test_superseded_filenames_single_version_is_not_superseded() -> None:
    """Test a package with only one version reports nothing superseded."""
    assert _superseded_filenames(["pipette_0.16.2.tgz"], ".tgz") == []


def test_superseded_filenames_keeps_highest_version() -> None:
    """Test the live pipette case: only the older .tgz is reported."""
    filenames = ["pipette_0.16.1.tgz", "pipette_0.16.2.tgz"]
    assert _superseded_filenames(filenames, ".tgz") == ["pipette_0.16.1.tgz"]


def test_superseded_filenames_compares_numerically_not_lexically() -> None:
    """Test 0.7.10 outranks 0.7.9 (a lexical sort would get this backwards)."""
    filenames = ["AcidDevTools_0.7.9.tgz", "AcidDevTools_0.7.10.tgz"]
    assert _superseded_filenames(filenames, ".tgz") == ["AcidDevTools_0.7.9.tgz"]


def test_superseded_filenames_multiple_packages_interleaved() -> None:
    """Test grouping is per-package when multiple packages are interleaved."""
    filenames = [
        "Cellosaurus_0.8.4.tgz",
        "pipette_0.16.1.tgz",
        "Cellosaurus_0.8.5.tgz",
        "pipette_0.16.2.tgz",
    ]
    result = _superseded_filenames(filenames, ".tgz")
    assert set(result) == {"Cellosaurus_0.8.4.tgz", "pipette_0.16.1.tgz"}


def test_superseded_filenames_source_suffix() -> None:
    """Test the .tar.gz suffix (source tarballs) works the same as .tgz."""
    filenames = ["goalie_0.7.9.tar.gz", "goalie_0.7.10.tar.gz"]
    assert _superseded_filenames(filenames, ".tar.gz") == ["goalie_0.7.9.tar.gz"]


def test_superseded_filenames_skips_unparseable_version() -> None:
    """Test an unparseable version is never reported as superseded."""
    filenames = ["Pkg_0.1.0-devel.tgz", "Pkg_0.1.0.tgz"]
    assert _superseded_filenames(filenames, ".tgz") == []
