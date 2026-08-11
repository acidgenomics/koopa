"""Vendor backend config-parsing unit tests.

Scope is limited to the pure config-parsing surface (vendor_config,
vendor_pull_priority, vendor_rewrite_url) -- no network calls. vendor_config()
is lru_cache'd, so every test clears the cache both before and after to avoid
leaking a stale config (or lack of one) across tests.
"""

from collections.abc import Generator
from pathlib import Path

import pytest
from koopa.vendor import vendor_config, vendor_pull_priority, vendor_rewrite_url


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


def test_vendor_config_valid_http_config_returns_dict(
    tmp_path: Path, monkeypatch: pytest.MonkeyPatch
) -> None:
    """A valid, enabled config with a recognized backend is returned as-is."""
    _write_vendor_json(
        tmp_path,
        '{"enabled": true, "backend": "http",'
        ' "http": {"base_url": "https://artifacts.example.com",'
        ' "src_repo": "koopa-src", "binary_repo": "koopa-binaries"}}',
    )
    monkeypatch.setattr("koopa.prefix.koopa_prefix", lambda: str(tmp_path))

    cfg = vendor_config()
    assert cfg is not None
    assert cfg["backend"] == "http"


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


_REMOTES_CONFIG = (
    '{"enabled": true, "backend": "http",'
    ' "http": {"base_url": "https://artifacts.example.com",'
    ' "src_repo": "koopa-src",'
    ' "remotes": {"github.com": "github-remote", ".gnu.org": "gnu-remote"}}}'
)


def test_vendor_rewrite_url_exact_host_match(
    tmp_path: Path, monkeypatch: pytest.MonkeyPatch
) -> None:
    """An exact hostname match rewrites through the mapped remote repo."""
    _write_vendor_json(tmp_path, _REMOTES_CONFIG)
    monkeypatch.setattr("koopa.prefix.koopa_prefix", lambda: str(tmp_path))

    url = vendor_rewrite_url("https://github.com/astral-sh/uv/releases/download/0.12.3/uv.tar.gz")

    assert url == (
        "https://artifacts.example.com/github-remote"
        "/astral-sh/uv/releases/download/0.12.3/uv.tar.gz"
    )


def test_vendor_rewrite_url_suffix_host_match(
    tmp_path: Path, monkeypatch: pytest.MonkeyPatch
) -> None:
    """A '.suffix' remotes key matches any host ending in that suffix."""
    _write_vendor_json(tmp_path, _REMOTES_CONFIG)
    monkeypatch.setattr("koopa.prefix.koopa_prefix", lambda: str(tmp_path))

    url = vendor_rewrite_url("https://ftpmirror.gnu.org/gnu/xz/xz-5.8.3.tar.gz")

    assert url == "https://artifacts.example.com/gnu-remote/gnu/xz/xz-5.8.3.tar.gz"


def test_vendor_rewrite_url_apex_domain_does_not_match_suffix_key(
    tmp_path: Path, monkeypatch: pytest.MonkeyPatch
) -> None:
    """'.gnu.org' matches subdomains only, not the bare apex 'gnu.org'."""
    _write_vendor_json(tmp_path, _REMOTES_CONFIG)
    monkeypatch.setattr("koopa.prefix.koopa_prefix", lambda: str(tmp_path))

    assert vendor_rewrite_url("https://gnu.org/gnu/xz/xz-5.8.3.tar.gz") is None


def test_vendor_rewrite_url_unmatched_host_returns_none(
    tmp_path: Path, monkeypatch: pytest.MonkeyPatch
) -> None:
    """A host absent from 'remotes' rewrites to nothing."""
    _write_vendor_json(tmp_path, _REMOTES_CONFIG)
    monkeypatch.setattr("koopa.prefix.koopa_prefix", lambda: str(tmp_path))

    assert vendor_rewrite_url("https://example.com/pkg-1.0.tar.gz") is None


def test_vendor_rewrite_url_preserves_path_and_query(
    tmp_path: Path, monkeypatch: pytest.MonkeyPatch
) -> None:
    """The rewritten URL keeps the original path and query string intact."""
    _write_vendor_json(tmp_path, _REMOTES_CONFIG)
    monkeypatch.setattr("koopa.prefix.koopa_prefix", lambda: str(tmp_path))

    url = vendor_rewrite_url("https://github.com/foo/bar/releases/download/v1?token=abc")

    assert url == (
        "https://artifacts.example.com/github-remote/foo/bar/releases/download/v1?token=abc"
    )


def test_vendor_rewrite_url_s3_backend_returns_none(
    tmp_path: Path, monkeypatch: pytest.MonkeyPatch
) -> None:
    """The 's3' backend has no 'remotes' equivalent; always returns None."""
    _write_vendor_json(
        tmp_path,
        '{"enabled": true, "backend": "s3", "s3": {"bucket": "my-bucket"}}',
    )
    monkeypatch.setattr("koopa.prefix.koopa_prefix", lambda: str(tmp_path))

    assert (
        vendor_rewrite_url("https://github.com/astral-sh/uv/releases/download/0.12.3/uv.tar.gz")
        is None
    )


def test_vendor_rewrite_url_no_config_returns_none(
    tmp_path: Path, monkeypatch: pytest.MonkeyPatch
) -> None:
    """No vendor.json at all rewrites to nothing."""
    monkeypatch.setattr("koopa.prefix.koopa_prefix", lambda: str(tmp_path))

    assert (
        vendor_rewrite_url("https://github.com/astral-sh/uv/releases/download/0.12.3/uv.tar.gz")
        is None
    )
