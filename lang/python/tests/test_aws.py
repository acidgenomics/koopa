"""AWS module unit tests."""

import os
from pathlib import Path
from unittest.mock import patch

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
