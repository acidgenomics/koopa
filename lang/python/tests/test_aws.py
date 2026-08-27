"""AWS module unit tests."""

import os
import subprocess
from pathlib import Path
from unittest.mock import MagicMock, patch

import pytest


def test_parse_dotenv_reads_key_value_pairs(tmp_path: Path) -> None:
    """Comments and blank lines are skipped; surrounding whitespace is trimmed."""
    from koopa.aws import _parse_dotenv

    env_file = tmp_path / ".env"
    env_file.write_text(
        "# comment\n\nAWS_ACCOUNT_ID = 123456789012\nKOOPA_BUILDER=1\nno-equals-sign\n"
    )
    assert _parse_dotenv(env_file) == {
        "AWS_ACCOUNT_ID": "123456789012",
        "KOOPA_BUILDER": "1",
    }


def test_parse_dotenv_missing_file_returns_empty(tmp_path: Path) -> None:
    """A nonexistent '.env' parses to an empty dict rather than raising."""
    from koopa.aws import _parse_dotenv

    assert _parse_dotenv(tmp_path / "does-not-exist.env") == {}


def test_dotenv_value_prefers_environment(monkeypatch: pytest.MonkeyPatch) -> None:
    """An 'os.environ' value wins over '.env' and short-circuits the file read."""
    from koopa.aws import dotenv_value

    monkeypatch.setenv("AWS_ACCOUNT_ID", "env-value")
    with patch("koopa.aws._parse_dotenv", return_value={"AWS_ACCOUNT_ID": "file-value"}) as mock:
        assert dotenv_value("AWS_ACCOUNT_ID") == "env-value"
    mock.assert_not_called()


def test_dotenv_value_falls_back_to_dotenv(monkeypatch: pytest.MonkeyPatch) -> None:
    """A '.env'-only value is returned without ever touching 'os.environ'."""
    from koopa.aws import dotenv_value

    monkeypatch.delenv("KOOPA_BUILDER", raising=False)
    with patch("koopa.aws._parse_dotenv", return_value={"KOOPA_BUILDER": "1"}):
        assert dotenv_value("KOOPA_BUILDER") == "1"
    assert "KOOPA_BUILDER" not in os.environ


def test_dotenv_value_absent_returns_empty_string(monkeypatch: pytest.MonkeyPatch) -> None:
    """A key present in neither source resolves to ''."""
    from koopa.aws import dotenv_value

    monkeypatch.delenv("KOOPA_BUILDER", raising=False)
    with patch("koopa.aws._parse_dotenv", return_value={}):
        assert dotenv_value("KOOPA_BUILDER") == ""


def test_aws_account_id_raises_when_absent(monkeypatch: pytest.MonkeyPatch) -> None:
    """Absent from both the environment and '.env' raises 'RuntimeError'."""
    from koopa.aws import aws_account_id

    monkeypatch.delenv("AWS_ACCOUNT_ID", raising=False)
    with patch("koopa.aws._parse_dotenv", return_value={}), pytest.raises(RuntimeError):
        aws_account_id()


def test_aws_account_id_reads_dotenv_without_mutating_environ(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """A '.env'-only account ID is usable without ever landing in 'os.environ'."""
    from koopa.aws import aws_account_id

    monkeypatch.delenv("AWS_ACCOUNT_ID", raising=False)
    with patch("koopa.aws._parse_dotenv", return_value={"AWS_ACCOUNT_ID": "123456789012"}):
        assert aws_account_id() == "123456789012"
    assert "AWS_ACCOUNT_ID" not in os.environ


def test_aws_env_override_sets_and_removes_keys(monkeypatch: pytest.MonkeyPatch) -> None:
    """A string value sets a key; 'None' removes it; 'AWS_PAGER' is always set."""
    from koopa.aws import _aws

    monkeypatch.setenv("AWS_PROFILE", "some-profile")
    with patch("koopa.aws.subprocess.run") as mock_run:
        mock_run.return_value = subprocess.CompletedProcess([], 0, "", "")
        _aws(
            "sts",
            "get-caller-identity",
            env={"AWS_CONFIG_FILE": os.devnull, "AWS_PROFILE": None},
        )
    run_env = mock_run.call_args.kwargs["env"]
    assert run_env["AWS_CONFIG_FILE"] == os.devnull
    assert "AWS_PROFILE" not in run_env
    assert run_env["AWS_PAGER"] == ""


def test_aws_ec2_stop_instance_identity_neutralizes_credentials(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """'instance_identity=True' drops AWS_PROFILE/AWS_ACCESS_KEY_ID and adds --region."""
    from koopa.aws import aws_ec2_stop

    monkeypatch.setenv("AWS_PROFILE", "some-profile")
    monkeypatch.setenv("AWS_ACCESS_KEY_ID", "AKIAEXAMPLE")
    with patch("koopa.aws.subprocess.run") as mock_run:
        mock_run.return_value = subprocess.CompletedProcess([], 0, "", "")
        aws_ec2_stop(["i-x"], region="us-east-1", instance_identity=True)
    cmd = mock_run.call_args.args[0]
    assert "--region" in cmd
    assert "us-east-1" in cmd
    assert "--profile" not in cmd
    run_env = mock_run.call_args.kwargs["env"]
    assert "AWS_PROFILE" not in run_env
    assert "AWS_ACCESS_KEY_ID" not in run_env


def test_aws_ec2_stop_without_instance_identity_keeps_ambient_env(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """The default (cross-account) path leaves 'AWS_PROFILE' untouched."""
    from koopa.aws import aws_ec2_stop

    monkeypatch.setenv("AWS_PROFILE", "some-profile")
    with patch("koopa.aws.subprocess.run") as mock_run:
        mock_run.return_value = subprocess.CompletedProcess([], 0, "", "")
        aws_ec2_stop(["i-x"])
    run_env = mock_run.call_args.kwargs["env"]
    assert run_env["AWS_PROFILE"] == "some-profile"


def test_imds_get_sends_token_then_uses_it_as_header() -> None:
    """The IMDSv2 token is fetched via PUT, then sent as a header on the GET."""
    from koopa.aws import _imds_get

    token_resp = MagicMock()
    token_resp.read.return_value = b"a-token"
    data_resp = MagicMock()
    data_resp.read.return_value = b"i-0123456789abcdef0"

    with patch("urllib.request.urlopen") as mock_urlopen:
        mock_urlopen.return_value.__enter__.side_effect = [token_resp, data_resp]
        result = _imds_get("meta-data/instance-id")

    assert result == "i-0123456789abcdef0"
    token_req = mock_urlopen.call_args_list[0].args[0]
    assert token_req.method == "PUT"
    data_req = mock_urlopen.call_args_list[1].args[0]
    assert data_req.headers["X-aws-ec2-metadata-token"] == "a-token"
