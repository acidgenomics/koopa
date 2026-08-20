"""Private PyPI index management unit tests."""

from unittest.mock import patch

import pytest
from koopa.pypi import _cloudfront_distribution_id


def test_cloudfront_distribution_id_returns_specific_value() -> None:
    """Test the site-specific env var is used, not a generic one."""
    values = {
        "AWS_CLOUDFRONT_DISTRIBUTION_ID_PYTHON": "EPYTHON123",
        "AWS_CLOUDFRONT_DISTRIBUTION_ID": "EGENERIC456",
    }
    with patch("koopa.aws.dotenv_value", side_effect=lambda k: values.get(k, "")):
        assert _cloudfront_distribution_id() == "EPYTHON123"


def test_cloudfront_distribution_id_raises_when_specific_missing_even_if_generic_set() -> None:
    """Test it fails loudly instead of silently falling back to a generic ID.

    Regression test: a stale/unrelated AWS_CLOUDFRONT_DISTRIBUTION_ID on a
    machine that never had AWS_CLOUDFRONT_DISTRIBUTION_ID_PYTHON configured
    used to silently invalidate the wrong CloudFront distribution, leaving
    python.acidgenomics.com serving a stale cached index with no error at
    all. See koopa CHANGELOG for the incident this fixes.
    """
    values = {"AWS_CLOUDFRONT_DISTRIBUTION_ID": "EGENERIC456"}
    with (
        patch("koopa.aws.dotenv_value", side_effect=lambda k: values.get(k, "")),
        pytest.raises(RuntimeError, match="AWS_CLOUDFRONT_DISTRIBUTION_ID_PYTHON"),
    ):
        _cloudfront_distribution_id()


def test_cloudfront_distribution_id_raises_when_both_missing() -> None:
    """Test it raises when nothing is set at all."""
    with (
        patch("koopa.aws.dotenv_value", return_value=""),
        pytest.raises(RuntimeError, match="AWS_CLOUDFRONT_DISTRIBUTION_ID_PYTHON"),
    ):
        _cloudfront_distribution_id()
