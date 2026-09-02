"""Unit tests for version_check internals.

Covers _is_prerelease, _friendly_network_error, and _is_retryable_network_error.
"""

import http.client
import json
import ssl
import urllib.error
from datetime import UTC, datetime, timedelta
from pathlib import Path
from unittest.mock import patch

import pytest
from koopa.version import sanitize_version
from koopa.version_check import (
    VersionCheckResult,
    _audit_version_excludes,
    _check_npm,
    _check_pypi,
    _check_rubygems,
    _dead_hosts,
    _fetch_first_reachable,
    _friendly_network_error,
    _held_message,
    _index_has_version,
    _is_prerelease,
    _is_retryable_network_error,
    _liblinear_tag_to_version,
    _NetworkUnavailableError,
    classify_app,
    update_app_json,
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


def test_is_retryable_bare_timeout_error() -> None:
    """A bare TimeoutError (e.g. a read timeout not wrapped in URLError) is retryable."""
    assert _is_retryable_network_error(TimeoutError()) is True


def test_is_retryable_value_error() -> None:
    """A non-network exception is not retryable."""
    assert _is_retryable_network_error(ValueError()) is False


# ── _check_pypi (P14D dependency cooldown) ───────────────────────────────────


def _pypi_file(days_old: int, *, yanked: bool = False) -> dict:
    uploaded = datetime.now(UTC) - timedelta(days=days_old)
    return {"upload_time_iso_8601": uploaded.isoformat(), "yanked": yanked}


def test_check_pypi_skips_release_inside_cooldown(monkeypatch: pytest.MonkeyPatch) -> None:
    """A release younger than 14 days is skipped in favor of the next-newest one."""
    data = {
        "info": {"version": "2.0.0"},
        "releases": {
            "1.0.0": [_pypi_file(days_old=30)],
            "2.0.0": [_pypi_file(days_old=1)],
        },
    }
    monkeypatch.setattr("koopa.version_check._http_get_json", lambda _url: data)
    assert _check_pypi("example") == "1.0.0"


def test_check_pypi_falls_back_when_all_releases_inside_cooldown(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """If every release is inside the cooldown, the newest one is still returned."""
    data = {
        "info": {"version": "2.0.0"},
        "releases": {
            "1.0.0": [_pypi_file(days_old=2)],
            "2.0.0": [_pypi_file(days_old=1)],
        },
    }
    monkeypatch.setattr("koopa.version_check._http_get_json", lambda _url: data)
    assert _check_pypi("example") == "2.0.0"


def test_check_pypi_ignores_yanked_files(monkeypatch: pytest.MonkeyPatch) -> None:
    """A release whose only file is yanked is excluded from eligibility."""
    data = {
        "info": {"version": "2.0.0"},
        "releases": {
            "1.0.0": [_pypi_file(days_old=30, yanked=True)],
            "2.0.0": [_pypi_file(days_old=1)],
        },
    }
    monkeypatch.setattr("koopa.version_check._http_get_json", lambda _url: data)
    assert _check_pypi("example") == "2.0.0"


def test_check_pypi_keeps_pin_already_on_a_young_release(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """A recent release already pinned as `current` is never reported as too high.

    Regression: mirrors the bashcov/RubyGems fix. Without whitelisting
    `current`, a package pinned to a release younger than 14 days would fall
    back to `data["info"]["version"]` and misreport the pin as "too high".
    """
    data = {
        "info": {"version": "1.0.0"},
        "releases": {
            "1.0.0": [_pypi_file(days_old=30)],
            "2.0.0": [_pypi_file(days_old=1)],
        },
    }
    monkeypatch.setattr("koopa.version_check._http_get_json", lambda _url: data)
    assert _check_pypi("example", current="2.0.0") == "2.0.0"


def test_check_pypi_skips_prerelease_releases(monkeypatch: pytest.MonkeyPatch) -> None:
    """A newer alpha/beta/rc release is never proposed over an older stable one.

    Regression: dbt and jupyterlab both got their pins walked forward through
    a 2.x alpha/beta series (e.g. 2.0.0b1 -> 2.0.0b2) because pre-releases
    were never excluded from the candidate pool.
    """
    data = {
        "info": {"version": "1.0.0"},
        "releases": {
            "1.0.0": [_pypi_file(days_old=30)],
            "2.0.0a1": [_pypi_file(days_old=30)],
            "2.0.0b1": [_pypi_file(days_old=30)],
            "2.0.0b2": [_pypi_file(days_old=1)],
        },
    }
    monkeypatch.setattr("koopa.version_check._http_get_json", lambda _url: data)
    assert _check_pypi("example") == "1.0.0"


def test_check_pypi_ignores_a_current_pin_stuck_on_a_prerelease(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """A pin already drifted onto a pre-release is not treated as eligible.

    Once a pin is stuck on e.g. `2.0.0b1`, the checker must recommend the
    latest *stable* release (so `is_pinned_too_high` can flag it), not
    another pre-release from the same series.
    """
    data = {
        "info": {"version": "1.0.0"},
        "releases": {
            "1.0.0": [_pypi_file(days_old=30)],
            "2.0.0b1": [_pypi_file(days_old=30)],
            "2.0.0b2": [_pypi_file(days_old=1)],
        },
    }
    monkeypatch.setattr("koopa.version_check._http_get_json", lambda _url: data)
    assert _check_pypi("example", current="2.0.0b1") == "1.0.0"


# ── _check_npm (deprecated-version skip) ─────────────────────────────────────


def test_check_npm_returns_newest_version(monkeypatch: pytest.MonkeyPatch) -> None:
    """With nothing deprecated, the newest version wins."""
    data = {
        "dist-tags": {"latest": "2.0.0"},
        "versions": {
            "1.0.0": {},
            "2.0.0": {},
        },
    }
    monkeypatch.setattr("koopa.version_check._http_get_json", lambda _url: data)
    assert _check_npm("example") == "2.0.0"


def test_check_npm_skips_deprecated_version(monkeypatch: pytest.MonkeyPatch) -> None:
    """A deprecated release is skipped in favor of the next-newest one."""
    data = {
        "dist-tags": {"latest": "2.0.0"},
        "versions": {
            "1.0.0": {},
            "2.0.0": {"deprecated": "compromised, see advisory"},
        },
    }
    monkeypatch.setattr("koopa.version_check._http_get_json", lambda _url: data)
    assert _check_npm("example") == "1.0.0"


def test_check_npm_falls_back_when_all_versions_deprecated(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """If every version is deprecated, the dist-tags latest is still returned."""
    data = {
        "dist-tags": {"latest": "2.0.0"},
        "versions": {
            "1.0.0": {"deprecated": "old"},
            "2.0.0": {"deprecated": "compromised, see advisory"},
        },
    }
    monkeypatch.setattr("koopa.version_check._http_get_json", lambda _url: data)
    assert _check_npm("example") == "2.0.0"


# ── _check_rubygems (14-day dependency cooldown) ─────────────────────────────


def _gem_release(number: str, days_old: int) -> dict:
    created_at = datetime.now(UTC) - timedelta(days=days_old)
    return {"number": number, "created_at": created_at.isoformat()}


def test_check_rubygems_skips_release_inside_cooldown(monkeypatch: pytest.MonkeyPatch) -> None:
    """A release younger than 14 days is skipped in favor of the next-newest one."""
    data = [
        _gem_release("2.0.0", days_old=1),
        _gem_release("1.0.0", days_old=30),
    ]
    monkeypatch.setattr("koopa.version_check._http_get_json", lambda _url: data)
    assert _check_rubygems("example") == "1.0.0"


def test_check_rubygems_falls_back_when_all_releases_inside_cooldown(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """If every release is inside the cooldown, the newest one is still returned."""
    data = [
        _gem_release("2.0.0", days_old=1),
        _gem_release("1.0.0", days_old=2),
    ]
    monkeypatch.setattr("koopa.version_check._http_get_json", lambda _url: data)
    assert _check_rubygems("example") == "2.0.0"


def test_check_rubygems_keeps_pin_already_on_a_young_release(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """A recent release already pinned as `current` is never reported as too high.

    Regression: bashcov 4.0.0 (published 8 days before this test was written)
    was already the adopted pin. Without whitelisting `current`, the cooldown
    fell back to 3.3.0 and the checker misreported the pin as "too high".
    """
    data = [
        _gem_release("4.0.0", days_old=8),
        _gem_release("3.3.0", days_old=30),
    ]
    monkeypatch.setattr("koopa.version_check._http_get_json", lambda _url: data)
    assert _check_rubygems("example", current="4.0.0") == "4.0.0"


# ── _fetch_first_reachable (dead-host circuit breaker) ──────────────────────


@pytest.fixture(autouse=True)
def _reset_dead_hosts() -> None:
    """Clear the module-level dead-host set so tests don't leak state."""
    _dead_hosts.clear()


def test_fetch_first_reachable_falls_through_to_working_base(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """A timeout on the first base falls through to the next base, which succeeds."""
    calls: list[str] = []

    def fake_get(base: str, timeout: int = 8, _retries: int = 1) -> str:
        calls.append(base)
        if "blocked" in base:
            raise TimeoutError("simulated connect timeout")
        return f"<html>{base}</html>"

    monkeypatch.setattr("koopa.version_check._http_get_text", fake_get)
    html = _fetch_first_reachable(["https://blocked.example/sed/", "https://good.example/sed/"])
    assert html == "<html>https://good.example/sed/</html>"
    assert calls == ["https://blocked.example/sed/", "https://good.example/sed/"]


def test_fetch_first_reachable_skips_previously_dead_host(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """A host that timed out on a prior call is skipped entirely on the next call.

    Regression test: _check_gnu() used to re-probe every unreachable GNU/Savannah
    mirror host once per app, burning a full timeout per app across 30+ apps. The
    circuit breaker records a dead host after one timeout and skips it on
    subsequent calls within the same process.
    """
    calls: list[str] = []

    def fake_get(base: str, timeout: int = 8, _retries: int = 1) -> str:
        calls.append(base)
        if "blocked" in base:
            raise TimeoutError("simulated connect timeout")
        return f"<html>{base}</html>"

    monkeypatch.setattr("koopa.version_check._http_get_text", fake_get)
    _fetch_first_reachable(["https://blocked.example/sed/", "https://good.example/sed/"])

    calls.clear()
    html = _fetch_first_reachable(["https://blocked.example/gzip/", "https://good.example/gzip/"])
    assert html == "<html>https://good.example/gzip/</html>"
    assert calls == ["https://good.example/gzip/"]


def test_fetch_first_reachable_does_not_blacklist_on_http_error(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """An HTTP error response (e.g. 404) does not mark the host dead.

    A 404 for one package says nothing about the host's reachability for
    another package; only connect/handshake timeouts should trip the breaker.
    """
    calls: list[str] = []

    def fake_get(base: str, timeout: int = 8, _retries: int = 1) -> str:
        calls.append(base)
        if "notfound" in base:
            raise urllib.error.HTTPError(base, 404, "Not Found", http.client.HTTPMessage(), None)
        return f"<html>{base}</html>"

    monkeypatch.setattr("koopa.version_check._http_get_text", fake_get)
    _fetch_first_reachable(["https://host.example/notfound/", "https://host.example/good/"])

    calls.clear()
    html = _fetch_first_reachable(["https://host.example/notfound/", "https://host.example/good/"])
    assert html == "<html>https://host.example/good/</html>"
    # The 404'd URL is still tried on the second call: 404 is not a dead-host signal.
    assert calls == ["https://host.example/notfound/", "https://host.example/good/"]


def test_fetch_first_reachable_raises_network_unavailable_when_all_fail(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """All bases timing out raises _NetworkUnavailableError."""

    def fake_get(_base: str, timeout: int = 8, _retries: int = 1) -> str:
        raise TimeoutError("simulated connect timeout")

    monkeypatch.setattr("koopa.version_check._http_get_text", fake_get)
    with pytest.raises(_NetworkUnavailableError):
        _fetch_first_reachable(["https://a.example/sed/", "https://b.example/sed/"])


# ── update_app_json artifact gate ────────────────────────────────────────────


def _write_app_json(tmp_path: Path, data: dict) -> None:
    etc_dir = tmp_path / "etc" / "koopa"
    etc_dir.mkdir(parents=True)
    (etc_dir / "app.json").write_text(json.dumps(data))


def test_update_app_json_holds_pin_when_artifact_not_staged(tmp_path: Path) -> None:
    """A gated app's pin is held, and reported, when its artifact isn't staged."""
    json_data = {
        "cellranger": {
            "version": "7.2.0",
            "installer_artifact": "installers/cellranger/{version}.tar.xz",
            "url": ["https://example.test/cellranger"],
        },
        "ripgrep": {"version": "14.0.0"},
    }
    _write_app_json(tmp_path, json_data)
    results = [
        VersionCheckResult("cellranger", "7.2.0", "10.0.0", "github", None),
        VersionCheckResult("ripgrep", "14.0.0", "14.1.0", "github", None),
    ]
    with (
        patch("koopa.version_check.koopa_prefix", return_value=str(tmp_path)),
        patch("koopa.version_check.export_app_json") as mock_export,
        patch("koopa.version_check.update_venv_version"),
        patch("koopa.app.import_app_json", return_value=json_data),
        patch("koopa.install._has_private_access", return_value=False),
        patch("koopa.version_check._has_acidgenomics_aws", return_value=False),
    ):
        count = update_app_json(results)
    written = mock_export.call_args[0][0]
    assert written["cellranger"]["version"] == "7.2.0"
    assert written["ripgrep"]["version"] == "14.1.0"
    assert count == 1


def test_update_app_json_bumps_when_artifact_staged(tmp_path: Path) -> None:
    """A gated app's pin is bumped once its artifact is confirmed staged."""
    json_data = {
        "cellranger": {
            "version": "7.2.0",
            "installer_artifact": "installers/cellranger/{version}.tar.xz",
            "url": ["https://example.test/cellranger"],
        },
    }
    _write_app_json(tmp_path, json_data)
    results = [VersionCheckResult("cellranger", "7.2.0", "10.0.0", "github", None)]
    with (
        patch("koopa.version_check.koopa_prefix", return_value=str(tmp_path)),
        patch("koopa.version_check.export_app_json") as mock_export,
        patch("koopa.version_check.update_venv_version"),
        patch("koopa.app.import_app_json", return_value=json_data),
        patch("koopa.install._has_private_access", return_value=True),
        patch("koopa.version_check._has_acidgenomics_aws", return_value=False),
        patch("koopa.aws.koopa_s3_bucket", return_value="artifacts-000000000000-us-east-1-an"),
        patch("koopa.aws.s3_object_exists", return_value=True),
    ):
        count = update_app_json(results)
    written = mock_export.call_args[0][0]
    assert written["cellranger"]["version"] == "10.0.0"
    assert count == 1


# ── update_app_json pip-index gate (pip-versioned installer modules) ────────


def test_update_app_json_holds_pin_when_index_lacks_version(tmp_path: Path) -> None:
    """A pin is held when the configured pip index doesn't have the latest version.

    ``pyright`` resolves to ``koopa.installers.pyright`` in the real
    ``PYTHON_INSTALLERS`` registry, which is in ``PIP_VERSIONED_INSTALLERS`` --
    gating must key off that module, not ``r.source`` (see the next test).
    """
    json_data = {
        "pyright": {"version": "1.1.411", "url": ["https://pypi.org/project/pyright/"]},
    }
    _write_app_json(tmp_path, json_data)
    results = [VersionCheckResult("pyright", "1.1.411", "1.1.412", "github", None)]
    with (
        patch("koopa.version_check.koopa_prefix", return_value=str(tmp_path)),
        patch("koopa.version_check.export_app_json") as mock_export,
        patch("koopa.version_check.update_venv_version"),
        patch("koopa.app.import_app_json", return_value=json_data),
        patch("koopa.version_check._pip_index_url", return_value="https://example.test/simple"),
        patch("koopa.version_check._index_has_version", return_value=False),
    ):
        count = update_app_json(results)
    written = mock_export.call_args[0][0]
    assert written["pyright"]["version"] == "1.1.411"
    assert count == 0


def test_update_app_json_pip_index_gate_ignores_a_non_pip_source_label(tmp_path: Path) -> None:
    """A `pypi`-labelled source alone must never trigger the gate.

    Regression test: pyright's real classify_app() source is "github" (its
    url list has a github.com entry that wins classify_app's priority order
    over its pypi.org entry), yet it is still a pip install and must be
    gated. The inverse bug -- gating on `r.source == "pypi"` -- let a fake
    app claiming that label through the gate for an app that PYTHON_INSTALLERS
    has no pip-versioned module for, and missed pyright entirely.
    """
    json_data = {
        "not-actually-pip-installed": {"version": "1.0.0", "url": ["https://example.test"]},
    }
    _write_app_json(tmp_path, json_data)
    results = [
        VersionCheckResult("not-actually-pip-installed", "1.0.0", "2.0.0", "pypi", None),
    ]
    with (
        patch("koopa.version_check.koopa_prefix", return_value=str(tmp_path)),
        patch("koopa.version_check.export_app_json") as mock_export,
        patch("koopa.version_check.update_venv_version"),
        patch("koopa.app.import_app_json", return_value=json_data),
        patch("koopa.version_check._pip_index_url", return_value="https://example.test/simple"),
        patch(
            "koopa.version_check._index_has_version",
            side_effect=AssertionError("must not be called for a non-pip-installed app"),
        ),
    ):
        count = update_app_json(results)
    written = mock_export.call_args[0][0]
    assert written["not-actually-pip-installed"]["version"] == "2.0.0"
    assert count == 1


def test_update_app_json_bumps_pin_when_no_index_configured(tmp_path: Path) -> None:
    """The pip-index gate is a no-op when no non-PyPI index is configured."""
    json_data = {
        "pyright": {"version": "1.1.411", "url": ["https://pypi.org/project/pyright/"]},
    }
    _write_app_json(tmp_path, json_data)
    results = [VersionCheckResult("pyright", "1.1.411", "1.1.412", "github", None)]
    with (
        patch("koopa.version_check.koopa_prefix", return_value=str(tmp_path)),
        patch("koopa.version_check.export_app_json") as mock_export,
        patch("koopa.version_check.update_venv_version"),
        patch("koopa.app.import_app_json", return_value=json_data),
        patch("koopa.version_check._pip_index_url", return_value=None),
        patch(
            "koopa.version_check._index_has_version",
            side_effect=AssertionError("must not be called when no index is configured"),
        ),
    ):
        count = update_app_json(results)
    written = mock_export.call_args[0][0]
    assert written["pyright"]["version"] == "1.1.412"
    assert count == 1


def test_update_app_json_pip_index_gate_ignores_non_pip_installed_app(tmp_path: Path) -> None:
    """The pip-index gate never applies to an app with no pip-versioned installer module."""
    json_data = {
        "ripgrep": {"version": "14.0.0", "url": ["https://github.com/BurntSushi/ripgrep"]},
    }
    _write_app_json(tmp_path, json_data)
    results = [VersionCheckResult("ripgrep", "14.0.0", "14.1.0", "github", None)]
    with (
        patch("koopa.version_check.koopa_prefix", return_value=str(tmp_path)),
        patch("koopa.version_check.export_app_json") as mock_export,
        patch("koopa.version_check.update_venv_version"),
        patch("koopa.app.import_app_json", return_value=json_data),
        patch("koopa.version_check._pip_index_url", return_value="https://example.test/simple"),
        patch(
            "koopa.version_check._index_has_version",
            side_effect=AssertionError("must not be called for a non-pip-installed app"),
        ),
    ):
        count = update_app_json(results)
    written = mock_export.call_args[0][0]
    assert written["ripgrep"]["version"] == "14.1.0"
    assert count == 1


def test_pip_versioned_installers_registry_matches_source() -> None:
    """`PIP_VERSIONED_INSTALLERS` must list every installer module that pip-installs a pin.

    A module added later that starts calling `install_python_package()` (or
    building its own `pip install <name>==<version>`), without being added to
    this registry, would silently skip the pip-index availability gate --
    exactly the bug that let `pyright` slip past `r.source == "pypi"` gating.
    """
    import koopa.installers as installers_pkg
    from koopa.installers import PIP_VERSIONED_INSTALLERS

    installers_dir = Path(installers_pkg.__file__).parent
    found = {
        f"koopa.installers.{path.stem}"
        for path in installers_dir.glob("*.py")
        if path.stem != "__init__"
        and ("install_python_package(" in path.read_text() or "pip_name}==" in path.read_text())
    }
    assert found == set(PIP_VERSIONED_INSTALLERS)


def test_index_has_version_fails_open_on_network_error() -> None:
    """`_index_has_version` returns True (never holds the pin) on a network error."""
    with patch(
        "koopa.version_check._http_get_text",
        side_effect=urllib.error.URLError("connection refused"),
    ):
        assert _index_has_version("https://example.test/simple", "pyright", "1.1.412") is True


def test_index_has_version_true_when_version_present() -> None:
    """`_index_has_version` finds an exact version among sibling versions on the index page."""
    html = (
        "<a href='pyright-1.1.411-py3-none-any.whl'>pyright-1.1.411-py3-none-any.whl</a>\n"
        "<a href='pyright-1.1.412-py3-none-any.whl'>pyright-1.1.412-py3-none-any.whl</a>\n"
    )
    with patch("koopa.version_check._http_get_text", return_value=html):
        assert _index_has_version("https://example.test/simple", "pyright", "1.1.412") is True
        assert _index_has_version("https://example.test/simple", "pyright", "1.1.413") is False


# ── version_exclude / version_granularity holds (_held_message) ─────────────


def test_held_message_holds_an_excluded_version() -> None:
    """A latest version on the exclusion list is held, not written."""
    msg = _held_message("node", "26.6.0", "26.8.0", ("26.8.0",), None)
    assert msg is not None
    assert "excluded" in msg
    assert "26.6.0" in msg


def test_held_message_allows_a_non_excluded_version() -> None:
    """A latest version not on the exclusion list bumps normally."""
    msg = _held_message("node", "26.6.0", "26.9.0", ("26.8.0",), None)
    assert msg is None


def test_held_message_minor_granularity_holds_a_patch_bump() -> None:
    """A patch-only bump is held when version_granularity is 'minor'."""
    msg = _held_message("hugo", "0.165.0", "0.165.1", (), "minor")
    assert msg is not None
    assert "not a minor" in msg


def test_held_message_minor_granularity_allows_a_minor_bump() -> None:
    """A minor bump is written when version_granularity is 'minor'."""
    msg = _held_message("hugo", "0.165.0", "0.166.0", (), "minor")
    assert msg is None


# ── version_exclude audit (_audit_version_excludes) ──────────────────────────


def test_audit_version_excludes_flags_a_stale_hold() -> None:
    """An exclusion list entirely below the current pin is reported as stale."""
    json_data = {"node": {"version": "26.9.0", "version_exclude": ["26.8.0"]}}
    contradictions, stale_holds = _audit_version_excludes(json_data)
    assert contradictions == []
    assert len(stale_holds) == 1
    assert "node" in stale_holds[0]


def test_audit_version_excludes_flags_a_contradiction() -> None:
    """A pin that is itself excluded is reported as a contradiction."""
    json_data = {"node": {"version": "26.8.0", "version_exclude": ["26.8.0"]}}
    contradictions, stale_holds = _audit_version_excludes(json_data)
    assert stale_holds == []
    assert len(contradictions) == 1
    assert "node" in contradictions[0]


def test_audit_version_excludes_is_silent_for_an_active_hold() -> None:
    """A hold that is neither stale nor contradictory raises nothing."""
    json_data = {"node": {"version": "26.6.0", "version_exclude": ["26.8.0"]}}
    contradictions, stale_holds = _audit_version_excludes(json_data)
    assert contradictions == []
    assert stale_holds == []


# ── update_app_json: version_exclude / version_match write-time gates ───────


def test_update_app_json_holds_pin_when_version_excluded(tmp_path: Path) -> None:
    """An excluded latest version is held at write time, even if it reaches here."""
    json_data = {
        "node": {"version": "26.6.0", "version_exclude": ["26.8.0"], "url": ["https://x"]},
    }
    _write_app_json(tmp_path, json_data)
    results = [VersionCheckResult("node", "26.6.0", "26.8.0", "conda", None)]
    with (
        patch("koopa.version_check.koopa_prefix", return_value=str(tmp_path)),
        patch("koopa.version_check.export_app_json") as mock_export,
        patch("koopa.version_check.update_venv_version"),
        patch("koopa.app.import_app_json", return_value=json_data),
    ):
        count = update_app_json(results)
    written = mock_export.call_args[0][0]
    assert written["node"]["version"] == "26.6.0"
    assert count == 0


def test_update_app_json_bumps_when_version_not_excluded(tmp_path: Path) -> None:
    """A latest version off the exclusion list bumps normally, proving the hold self-heals."""
    json_data = {
        "node": {"version": "26.6.0", "version_exclude": ["26.8.0"], "url": ["https://x"]},
    }
    _write_app_json(tmp_path, json_data)
    results = [VersionCheckResult("node", "26.6.0", "26.9.0", "conda", None)]
    with (
        patch("koopa.version_check.koopa_prefix", return_value=str(tmp_path)),
        patch("koopa.version_check.export_app_json") as mock_export,
        patch("koopa.version_check.update_venv_version"),
        patch("koopa.app.import_app_json", return_value=json_data),
    ):
        count = update_app_json(results)
    written = mock_export.call_args[0][0]
    assert written["node"]["version"] == "26.9.0"
    assert count == 1


def test_update_app_json_holds_a_version_match_group_on_disagreement(tmp_path: Path) -> None:
    """A version_match group is held whole when its members disagree on the latest version."""
    json_data = {
        "xorg-libxcb": {"version": "1.17.0", "url": ["https://x"]},
        "xorg-xcb-proto": {
            "version": "1.17.0",
            "version_match": "xorg-libxcb",
            "url": ["https://x"],
        },
    }
    _write_app_json(tmp_path, json_data)
    results = [
        VersionCheckResult("xorg-libxcb", "1.17.0", "1.18.0", "dirlist", None),
        VersionCheckResult("xorg-xcb-proto", "1.17.0", "1.17.1", "dirlist", None),
    ]
    with (
        patch("koopa.version_check.koopa_prefix", return_value=str(tmp_path)),
        patch("koopa.version_check.export_app_json") as mock_export,
        patch("koopa.version_check.update_venv_version"),
        patch("koopa.app.import_app_json", return_value=json_data),
    ):
        count = update_app_json(results)
    written = mock_export.call_args[0][0]
    assert written["xorg-libxcb"]["version"] == "1.17.0"
    assert written["xorg-xcb-proto"]["version"] == "1.17.0"
    assert count == 0


def test_update_app_json_bumps_a_version_match_group_on_agreement(tmp_path: Path) -> None:
    """A version_match group bumps together when its members agree on the latest version."""
    json_data = {
        "xorg-libxcb": {"version": "1.17.0", "url": ["https://x"]},
        "xorg-xcb-proto": {
            "version": "1.17.0",
            "version_match": "xorg-libxcb",
            "url": ["https://x"],
        },
    }
    _write_app_json(tmp_path, json_data)
    results = [
        VersionCheckResult("xorg-libxcb", "1.17.0", "1.18.0", "dirlist", None),
        VersionCheckResult("xorg-xcb-proto", "1.17.0", "1.18.0", "dirlist", None),
    ]
    with (
        patch("koopa.version_check.koopa_prefix", return_value=str(tmp_path)),
        patch("koopa.version_check.export_app_json") as mock_export,
        patch("koopa.version_check.update_venv_version"),
        patch("koopa.app.import_app_json", return_value=json_data),
    ):
        count = update_app_json(results)
    written = mock_export.call_args[0][0]
    assert written["xorg-libxcb"]["version"] == "1.18.0"
    assert written["xorg-xcb-proto"]["version"] == "1.18.0"
    assert count == 2


# ── classify_app ─────────────────────────────────────────────────────────────


def test_classify_app_registry_url_fallback_for_bespoke_installer() -> None:
    """An app with a dedicated installer module still classifies via its PyPI URL."""
    info = {
        "installer": "playwright",
        "url": ["https://playwright.dev/", "https://pypi.org/project/playwright"],
        "version": "1.62.0",
    }
    spec = classify_app("playwright", info)
    assert spec is not None
    assert spec.source == "pypi"
    # classify_app wraps the pypi check_fn to bind the current pin (see the
    # cooldown fix below), so args is empty; behavior is verified functionally.
    assert spec.args == ()


def test_classify_app_python_plugin_uses_pypi_not_monorepo_github() -> None:
    """A `python-plugin` installer classifies via PyPI, not a shared GitHub repo.

    Regression guard: dbt adapters (dbt-postgres, dbt-redshift, dbt-bigquery,
    dbt-snowflake) install via `python-plugin` and list the shared
    `dbt-labs/dbt-adapters` monorepo as their only GitHub URL. That repo's
    GitHub Releases are stale (latest release tag v1.10.4, from 2024), so
    falling through to the `github` classifier produced a version far
    older than the package's real PyPI releases.
    """
    info = {
        "installer": "python-plugin",
        "installer_args": {"parent_app": "dbt"},
        "url": ["https://docs.getdbt.com", "https://github.com/dbt-labs/dbt-adapters"],
        "version": "1.11.0",
    }
    spec = classify_app("dbt-postgres", info)
    assert spec is not None
    assert spec.source == "pypi"


def test_classify_app_pypi_wrap_passes_current_pin_to_check_fn(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """classify_app binds the current pin into a pypi spec's check_fn.

    Regression guard: this covers both a dynamically classified app and a
    hardcoded `_SPECIAL_CASES` entry (e.g. "uv"), since a naive fix at the
    `_classify_generic`/`_classify_by_registry_url` call sites alone would
    miss every hardcoded pypi entry in `_SPECIAL_CASES`.
    """
    data = {
        "info": {"version": "1.0.0"},
        "releases": {
            "2.0.5": [{"upload_time_iso_8601": datetime.now(UTC).isoformat(), "yanked": False}],
        },
    }
    monkeypatch.setattr("koopa.version_check._http_get_json", lambda _url: data)
    spec = classify_app("uv", {"version": "2.0.5"})
    assert spec is not None
    assert spec.source == "pypi"
    # 2.0.5 is younger than the cooldown, but it's the current pin, so it must
    # be returned as-is, not the stale `data["info"]["version"]` fallback.
    assert spec.check_fn(*spec.args) == "2.0.5"


def test_classify_app_no_unsupported_apps_in_registry() -> None:
    """Every supported app in the real app.json classifies to a check strategy.

    Regression guard: a bespoke installer module with no GitHub URL and no
    matching known pattern silently fell through to `None` (reported as
    'Unsupported'). Any future app hitting the same gap should fail this test
    instead of only showing up in a 'koopa develop check-app-versions' run.
    """
    from koopa.app import import_app_json

    json_data = import_app_json()
    unsupported = []
    for name, entry in json_data.items():
        if not isinstance(entry, dict):
            continue
        if entry.get("alias_of") or entry.get("removed") or entry.get("version_pin"):
            continue
        if not entry.get("version"):
            continue
        if classify_app(name, entry) is None:
            unsupported.append(name)
    assert unsupported == []


# ── _liblinear_tag_to_version ─────────────────────────────────────────────────


@pytest.mark.parametrize(
    ("tag", "expected"),
    [
        ("v250", "2.50"),
        ("v134", "1.34"),
        ("v2.51", "2.51"),
        ("vX", None),
        ("v1000", None),
    ],
)
def test_liblinear_tag_to_version(tag: str, expected: str | None) -> None:
    """Test translation of a liblinear git tag to a version string."""
    assert _liblinear_tag_to_version(tag) == expected
