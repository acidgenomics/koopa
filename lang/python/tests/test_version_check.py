"""Unit tests for version_check internals.

Covers _is_prerelease, _friendly_network_error, and _is_retryable_network_error.
"""

import http.client
import ssl
import urllib.error

import pytest
from koopa.version import sanitize_version
from koopa.version_check import (
    _friendly_network_error,
    _is_prerelease,
    _is_retryable_network_error,
)

# ── _is_prerelease ─────────────────────────────────────────────────────────


@pytest.mark.parametrize(
    "version",
    [
        "1.92.0.beta1",
        "1.92.0-rc1",
        "1.2.0alpha",
        "3.0.0-dev",
        "2.0.0.rc2",
        "1.0.0-preview",
        "2.0.0.snapshot",
        "1.0.0-nightly",
        "0.1.0canary",
        "1.0.0-pre",
        "1.0.0.rc",
        "2.0.0-BETA1",
        "1.0.0.RC3",
    ],
)
def test_is_prerelease_matches(version: str) -> None:
    """Pre-release markers are detected in a variety of positions."""
    assert _is_prerelease(version) is True


@pytest.mark.parametrize(
    "version",
    [
        "1.1.1w",
        "1.2.3a",
        "2.55.0",
        "1.91.0-1",
        "1.2.3",
        "1.91.0",
        "2.40.1",
        "10.0.0",
        "a0b1c2d3e4f5a0b1c2d3e4f5a0b1c2d3e4f5a0b1",  # 40-char SHA
    ],
)
def test_is_prerelease_rejects(version: str) -> None:
    """Stable versions (including single-letter suffixes) are not treated as pre-release."""
    assert _is_prerelease(version) is False


@pytest.mark.parametrize(
    "version",
    [
        "3.15.0beta2",
        "3.14.0rc1",
        "1.2.0alpha",
        "1.92.0.beta1",
    ],
)
def test_is_prerelease_survives_sanitize_version(version: str) -> None:
    """A pre-release marker must still be detected after sanitize_version().

    Regression test: sanitize_version() previously truncated pre-release
    suffixes down to a single letter (e.g. '3.15.0beta2' -> '3.15.0b'), which
    made this same _is_prerelease() check fail open in
    check_app_versions()._run_check(), letting a geos beta land in app.json.
    """
    assert _is_prerelease(sanitize_version(version)) is True


# ── _friendly_network_error ────────────────────────────────────────────────


def _make_http_error(code: int) -> urllib.error.HTTPError:
    return urllib.error.HTTPError("http://x", code, "phrase", http.client.HTTPMessage(), None)


@pytest.mark.parametrize("code", [429, 403, 404, 500])
def test_friendly_network_error_http_status(code: int) -> None:
    """HTTPError reports its status code."""
    assert _friendly_network_error(_make_http_error(code)) == f"check failed (HTTP {code})"


def test_friendly_network_error_timeout() -> None:
    """TimeoutError maps to network timeout."""
    assert _friendly_network_error(TimeoutError()) == "check failed (network timeout)"


def test_friendly_network_error_connection_reset() -> None:
    """ConnectionResetError maps to connection reset."""
    assert _friendly_network_error(ConnectionResetError()) == "check failed (connection reset)"


def test_friendly_network_error_ssl_timed_out() -> None:
    """SSLError containing 'timed out' maps to network timeout."""
    exc = ssl.SSLError("the connection timed out")
    assert _friendly_network_error(exc) == "check failed (network timeout)"


def test_friendly_network_error_ssl_other() -> None:
    """SSLError without 'timed out' maps to SSL error."""
    exc = ssl.SSLError("certificate verify failed")
    assert _friendly_network_error(exc) == "check failed (SSL error)"


def test_friendly_network_error_urlerror_oserror() -> None:
    """URLError wrapping an OSError maps to network error."""
    assert _friendly_network_error(urllib.error.URLError(OSError("dns failure"))) == (
        "check failed (network error)"
    )


def test_friendly_network_error_urlerror_string() -> None:
    """URLError with a string reason maps to connection error."""
    assert _friendly_network_error(urllib.error.URLError("unknown")) == (
        "check failed (connection error)"
    )


def test_friendly_network_error_non_network() -> None:
    """Non-network exceptions return None."""
    assert _friendly_network_error(ValueError("bad input")) is None


# ── _is_retryable_network_error ────────────────────────────────────────────


@pytest.mark.parametrize("code", [429, 403, 500, 503])
def test_is_retryable_http_retryable(code: int) -> None:
    """429, 403, and 5xx HTTP errors are retryable."""
    assert _is_retryable_network_error(_make_http_error(code)) is True


@pytest.mark.parametrize("code", [400, 404])
def test_is_retryable_http_not_retryable(code: int) -> None:
    """4xx errors other than 429/403 are not retryable."""
    assert _is_retryable_network_error(_make_http_error(code)) is False


def test_is_retryable_urlerror_timeout() -> None:
    """URLError wrapping a TimeoutError is retryable."""
    assert _is_retryable_network_error(urllib.error.URLError(TimeoutError())) is True


def test_is_retryable_urlerror_oserror() -> None:
    """URLError wrapping a plain OSError is not retryable."""
    assert _is_retryable_network_error(urllib.error.URLError(OSError())) is False


def test_is_retryable_ssl_error() -> None:
    """A bare SSLError is retryable."""
    assert _is_retryable_network_error(ssl.SSLError()) is True


def test_is_retryable_connection_reset() -> None:
    """A bare ConnectionResetError is retryable."""
    assert _is_retryable_network_error(ConnectionResetError()) is True


def test_is_retryable_value_error() -> None:
    """A non-network exception is not retryable."""
    assert _is_retryable_network_error(ValueError()) is False
