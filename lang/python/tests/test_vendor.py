"""Vendor backend config-parsing unit tests.

Scope is limited to the pure config-parsing surface (vendor_config,
vendor_pull_priority) -- no network calls. vendor_config() is lru_cache'd, so
every test clears the cache both before and after to avoid leaking a stale
config (or lack of one) across tests.
"""

from collections.abc import Generator
from pathlib import Path

import pytest
from koopa.vendor import vendor_config, vendor_pull_priority


@pytest.fixture(autouse=True)
def _clear_vendor_config_cache() -> Generator[None]:
    """Clear the vendor_config() lru_cache before and after each test."""
    vendor_config.cache_clear()
    yield
    vendor_config.cache_clear()


def _write_vendor_json(prefix: Path, content: str) -> None:
    etc_koopa = prefix / "etc" / "koopa"
    etc_koopa.mkdir(parents=True)
    (etc_koopa / "vendor.json").write_text(content)


def test_vendor_config_missing_file_returns_none(
    tmp_path: Path, monkeypatch: pytest.MonkeyPatch
) -> None:
    """No etc/koopa/vendor.json present returns None."""
    monkeypatch.setattr("koopa.prefix.koopa_prefix", lambda: str(tmp_path))

    assert vendor_config() is None


def test_vendor_config_disabled_returns_none(
    tmp_path: Path, monkeypatch: pytest.MonkeyPatch
) -> None:
    """'enabled': false (the documented default) returns None."""
    _write_vendor_json(tmp_path, '{"enabled": false, "backend": "s3"}')
    monkeypatch.setattr("koopa.prefix.koopa_prefix", lambda: str(tmp_path))

    assert vendor_config() is None


def test_vendor_config_unknown_backend_returns_none(
    tmp_path: Path, monkeypatch: pytest.MonkeyPatch
) -> None:
    """An unrecognized 'backend' value is ignored, not trusted."""
    _write_vendor_json(tmp_path, '{"enabled": true, "backend": "ftp"}')
    monkeypatch.setattr("koopa.prefix.koopa_prefix", lambda: str(tmp_path))

    assert vendor_config() is None


def test_vendor_config_invalid_json_returns_none(
    tmp_path: Path, monkeypatch: pytest.MonkeyPatch
) -> None:
    """Malformed JSON is treated the same as no config, not an exception."""
    _write_vendor_json(tmp_path, "{not valid json")
    monkeypatch.setattr("koopa.prefix.koopa_prefix", lambda: str(tmp_path))

    assert vendor_config() is None


def test_vendor_config_valid_artifactory_config_returns_dict(
    tmp_path: Path, monkeypatch: pytest.MonkeyPatch
) -> None:
    """A valid, enabled config with a recognized backend is returned as-is."""
    _write_vendor_json(
        tmp_path,
        '{"enabled": true, "backend": "artifactory",'
        ' "artifactory": {"base_url": "https://artifacts.example.com",'
        ' "src_repo": "koopa-src", "binary_repo": "koopa-binaries"}}',
    )
    monkeypatch.setattr("koopa.prefix.koopa_prefix", lambda: str(tmp_path))

    cfg = vendor_config()
    assert cfg is not None
    assert cfg["backend"] == "artifactory"


def test_vendor_pull_priority_defaults_to_vendor_first(
    tmp_path: Path, monkeypatch: pytest.MonkeyPatch
) -> None:
    """No vendor config at all defaults pull_priority to 'vendor_first'."""
    monkeypatch.setattr("koopa.prefix.koopa_prefix", lambda: str(tmp_path))

    assert vendor_pull_priority() == "vendor_first"


def test_vendor_pull_priority_reads_configured_value(
    tmp_path: Path, monkeypatch: pytest.MonkeyPatch
) -> None:
    """An explicit 'pull_priority': 'vendor_only' is honored."""
    _write_vendor_json(
        tmp_path,
        '{"enabled": true, "backend": "s3", "pull_priority": "vendor_only",'
        ' "s3": {"bucket": "my-bucket"}}',
    )
    monkeypatch.setattr("koopa.prefix.koopa_prefix", lambda: str(tmp_path))

    assert vendor_pull_priority() == "vendor_only"
