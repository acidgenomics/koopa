"""R package repository management unit tests."""

from unittest.mock import patch

import pytest
from koopa.cran import _cloudfront_distribution_id, _superseded_filenames


def test_cloudfront_distribution_id_returns_specific_value() -> None:
    """Test the site-specific env var is used, not a generic one."""
    values = {
        "AWS_CLOUDFRONT_DISTRIBUTION_ID_R": "ER123",
        "AWS_CLOUDFRONT_DISTRIBUTION_ID": "EGENERIC456",
    }
    with patch("koopa.aws.dotenv_value", side_effect=lambda k: values.get(k, "")):
        assert _cloudfront_distribution_id() == "ER123"


def test_cloudfront_distribution_id_raises_when_specific_missing_even_if_generic_set() -> None:
    """Test it fails loudly instead of silently falling back to a generic ID.

    See the identical regression test in test_pypi.py for the incident this
    fixes (koopa.pypi's sibling function had the same unsafe fallback).
    """
    values = {"AWS_CLOUDFRONT_DISTRIBUTION_ID": "EGENERIC456"}
    with (
        patch("koopa.aws.dotenv_value", side_effect=lambda k: values.get(k, "")),
        pytest.raises(RuntimeError, match="AWS_CLOUDFRONT_DISTRIBUTION_ID_R"),
    ):
        _cloudfront_distribution_id()


def test_cloudfront_distribution_id_raises_when_both_missing() -> None:
    """Test it raises when nothing is set at all."""
    with (
        patch("koopa.aws.dotenv_value", return_value=""),
        pytest.raises(RuntimeError, match="AWS_CLOUDFRONT_DISTRIBUTION_ID_R"),
    ):
        _cloudfront_distribution_id()


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
