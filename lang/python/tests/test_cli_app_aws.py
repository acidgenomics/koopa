"""Tests for koopa app aws ec2 stop routing."""

from unittest.mock import patch

from koopa.cli_app import _handle_aws_ec2_stop


def test_aws_ec2_stop_no_args_uses_instance_identity() -> None:
    """No instance IDs and no --profile means 'stop the host I am on'."""
    with (
        patch("koopa.aws.aws_ec2_instance_id", return_value="i-self") as mock_id,
        patch("koopa.aws.aws_ec2_region", return_value="us-east-1") as mock_region,
        patch("koopa.aws.aws_ec2_stop") as mock_stop,
    ):
        _handle_aws_ec2_stop([])
    mock_id.assert_called_once()
    mock_region.assert_called_once()
    mock_stop.assert_called_once_with(["i-self"], region="us-east-1", instance_identity=True)


def test_aws_ec2_stop_explicit_id_uses_ambient_chain() -> None:
    """A named instance ID keeps today's behavior: the ambient credential chain."""
    with patch("koopa.aws.aws_ec2_stop") as mock_stop:
        _handle_aws_ec2_stop(["i-other"])
    mock_stop.assert_called_once_with(["i-other"], profile=None)


def test_aws_ec2_stop_explicit_profile_uses_ambient_chain() -> None:
    """A named --profile also keeps the ambient chain, even with no instance ID."""
    with (
        patch("koopa.aws.aws_ec2_instance_id", return_value="i-self") as mock_id,
        patch("koopa.aws.aws_ec2_stop") as mock_stop,
    ):
        _handle_aws_ec2_stop(["--profile", "some-profile"])
    mock_id.assert_called_once()
    mock_stop.assert_called_once_with(["i-self"], profile="some-profile")
