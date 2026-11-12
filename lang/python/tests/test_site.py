"""koopa website publishing unit tests."""

from unittest.mock import patch

import pytest
from koopa.site import _cloudfront_distribution_id


@pytest.mark.parametrize(
    ("args", "dryrun", "invalidate"),
    [
        ([], False, True),
        (["--dry-run"], True, True),
        (["--dryrun", "--no-invalidate"], True, False),
    ],
)
def test_publish_docs_cli_flags(args: list[str], dryrun: bool, invalidate: bool) -> None:
    """Forward the preferred dry-run flag and its legacy alias safely."""
    from koopa.cli_develop import _handle_publish_docs

    with patch("koopa.site.publish_docs") as publish:
        _handle_publish_docs(args)

    publish.assert_called_once_with(invalidate=invalidate, dryrun=dryrun)


def test_cloudfront_distribution_id_returns_specific_value() -> None:
    """Test the site-specific env var is used, not a generic one."""
    values = {
        "AWS_CLOUDFRONT_DISTRIBUTION_ID_KOOPA": "EKOOPA123",
        "AWS_CLOUDFRONT_DISTRIBUTION_ID": "EGENERIC456",
    }
    with patch("koopa.aws.dotenv_value", side_effect=lambda k: values.get(k, "")):
        assert _cloudfront_distribution_id() == "EKOOPA123"


def test_cloudfront_distribution_id_raises_when_specific_missing_even_if_generic_set() -> None:
    """Test it fails loudly instead of silently falling back to a generic ID.

    See the identical regression test in test_pypi.py for the incident this
    fixes (koopa.pypi's sibling function had the same unsafe fallback).
    """
    values = {"AWS_CLOUDFRONT_DISTRIBUTION_ID": "EGENERIC456"}
    with (
        patch("koopa.aws.dotenv_value", side_effect=lambda k: values.get(k, "")),
        pytest.raises(RuntimeError, match="AWS_CLOUDFRONT_DISTRIBUTION_ID_KOOPA"),
    ):
        _cloudfront_distribution_id()


def test_cloudfront_distribution_id_raises_when_both_missing() -> None:
    """Test it raises when nothing is set at all."""
    with (
        patch("koopa.aws.dotenv_value", return_value=""),
        pytest.raises(RuntimeError, match="AWS_CLOUDFRONT_DISTRIBUTION_ID_KOOPA"),
    ):
        _cloudfront_distribution_id()
