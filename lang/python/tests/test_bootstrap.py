"""bootstrap.sh <-> koopa.vendor / app.json consistency tests.

bootstrap.sh is POSIX sh that runs before any koopa Python interpreter
exists, so it cannot import koopa.vendor -- its vendor_load()/
vendor_src_url()/vendor_rewrite_url() functions are a hand-written sh port of
koopa.vendor's Python functions, and its install_*() koopa-mirror URLs are a
hand-maintained mirror of koopa.version_check._bootstrap_app_map() and
etc/koopa/app.json. Nothing enforces either pairing at the language level, so
these tests read and execute the real bootstrap.sh in this checkout and
assert both stay in sync -- this is the test that would have caught
bootstrap.sh hardcoding 'src/openssl/' and 'src/python/' while
koopa.develop mirror-src uploads under the app.json keys 'openssl3' and
'python3.12'.
"""

import json
import os
import subprocess
from collections.abc import Generator
from pathlib import Path

import pytest
from koopa.prefix import koopa_prefix
from koopa.vendor import vendor_config, vendor_rewrite_url

_REPO_ROOT = Path(koopa_prefix())
_BOOTSTRAP_SH = _REPO_ROOT / "bootstrap.sh"
_SOURCE_BUILD_FUNCTIONS = ("perl", "openssl", "python", "bzip2", "xz", "libffi", "zlib")


@pytest.fixture(autouse=True)
def _clear_vendor_config_cache(monkeypatch: pytest.MonkeyPatch, tmp_path: Path) -> Generator[None]:
    """Isolate XDG_CONFIG_HOME and clear the vendor_config() lru_cache.

    Mirrors the isolation in test_vendor.py's fixture: both vendor_load() (sh)
    and vendor_config() (Python) now check XDG_CONFIG_HOME before falling
    back to 'etc/koopa/vendor.json', so a real '~/.config/koopa/vendor.json'
    on the host running these tests must never be reachable.
    """
    monkeypatch.setenv("XDG_CONFIG_HOME", str(tmp_path / "xdg-empty"))
    vendor_config.cache_clear()
    yield
    vendor_config.cache_clear()


def _function_defs_only() -> str:
    """Return bootstrap.sh's text up to (not including) the 'SCRIPT_DIR=' line.

    That line marks the end of function definitions and the start of
    top-level execution, which ends in an unconditional 'main "$@"' -- never
    something a test should let run.
    """
    text = _BOOTSTRAP_SH.read_text()
    marker = "\nSCRIPT_DIR="
    return text[: text.index(marker)]


def _capture_source_build_calls() -> dict[str, dict[str, str]]:
    """Call each source-build install_*() with download_with_fallback() stubbed.

    The stub captures <name>, the in-scope __kvar_version, and whichever URL
    argument targets koopa.acidgenomics.com, then fails immediately (no
    network access, no compiling). Returns
    {function_name: {"name": ..., "version": ..., "koopa_url": ...}}.
    """
    stub = """
download_with_fallback() {
    __captured_name="$1"
    __captured_version="$__kvar_version"
    shift 2
    __captured_koopa_url=""
    for __captured_url in "$@"
    do
        case "$__captured_url" in
            https://koopa.acidgenomics.com/*) __captured_koopa_url="$__captured_url" ;;
        esac
    done
    printf 'CAPTURE\\t%s\\t%s\\t%s\\n' \\
        "$__captured_name" "$__captured_version" "$__captured_koopa_url"
    return 1
}
"""
    calls = "\n".join(f"( install_{fn} ) || true" for fn in _SOURCE_BUILD_FUNCTIONS)
    script = (
        "set -eu\n"
        f"{_function_defs_only()}\n"
        f'KOOPA_PREFIX="{_REPO_ROOT}"\n'
        'PREFIX="/tmp/koopa-test-bootstrap-prefix"\n'
        'DESTDIR=""\n'
        '_curl_verbose=""\n'
        '_make_verbose=""\n'
        f"{stub}\n"
        f"{calls}\n"
    )
    result = subprocess.run(
        ["sh", "-c", script],
        capture_output=True,
        text=True,
        check=True,
    )
    lines = [line for line in result.stdout.splitlines() if line.startswith("CAPTURE\t")]
    assert len(lines) == len(_SOURCE_BUILD_FUNCTIONS), (
        f"expected {len(_SOURCE_BUILD_FUNCTIONS)} install_*() calls to reach"
        f" download_with_fallback(), got {len(lines)}: {lines!r}\nstderr: {result.stderr}"
    )
    captured = {}
    for fn, line in zip(_SOURCE_BUILD_FUNCTIONS, lines, strict=True):
        _, name, version, koopa_url = line.split("\t")
        captured[fn] = {"name": name, "version": version, "koopa_url": koopa_url}
    return captured


def test_bootstrap_koopa_mirror_names_match_app_json_keys() -> None:
    """Every install_*()'s koopa-mirror path segment is a real app.json key.

    Regression test: bootstrap.sh hardcoded 'src/openssl/' and 'src/python/',
    but koopa.develop mirror-src uploads under the app.json key ('openssl3',
    'python3.12'), 404ing both against the real mirror.
    """
    from koopa.version_check import _bootstrap_app_map

    app_map = _bootstrap_app_map()
    captured = _capture_source_build_calls()
    for fn_name, fields in captured.items():
        expected_name = app_map[fn_name]
        assert fields["name"] == expected_name, (
            f"install_{fn_name}() passes name={fields['name']!r} to"
            f" download_with_fallback(), but app.json key is {expected_name!r}"
        )
        assert fields["koopa_url"].startswith(
            f"https://koopa.acidgenomics.com/src/{expected_name}/"
        ), (
            f"install_{fn_name}()'s koopa-mirror URL {fields['koopa_url']!r}"
            f" does not match the app.json key {expected_name!r}"
        )


def test_bootstrap_pinned_versions_match_app_json() -> None:
    """Every install_*()'s pinned __kvar_version equals its app.json version.

    update_bootstrap() (koopa.version_check) is what is supposed to keep
    these in sync on every 'koopa develop check-versions' run; this asserts
    that invariant actually held for the versions currently pinned.
    """
    from koopa.version_check import _bootstrap_app_map

    app_map = _bootstrap_app_map()
    app_json = json.loads((_REPO_ROOT / "etc" / "koopa" / "app.json").read_text())
    captured = _capture_source_build_calls()
    for fn_name, fields in captured.items():
        app_key = app_map[fn_name]
        expected_version = app_json[app_key]["version"]
        assert fields["version"] == expected_version, (
            f"install_{fn_name}() is pinned to {fields['version']!r}, but"
            f" app.json[{app_key!r}].version is {expected_version!r}"
        )


def _run_vendor_sh(
    script_body: str,
    vendor_json: dict,
    tmp_path: Path,
    *,
    xdg_vendor_json: dict | None = None,
) -> str:
    """Run a bootstrap.sh function-def snippet against a fixture vendor.json.

    Writes 'vendor_json' under '<tmp_path>/etc/koopa/vendor.json'. When
    'xdg_vendor_json' is given, also writes it under an isolated
    XDG_CONFIG_HOME so precedence tests can exercise vendor_load()'s
    XDG-first lookup, matching koopa.vendor.vendor_config()'s search order.
    """
    etc_koopa = tmp_path / "etc" / "koopa"
    etc_koopa.mkdir(parents=True)
    (etc_koopa / "vendor.json").write_text(json.dumps(vendor_json))
    xdg_home = tmp_path / "xdg-empty"
    if xdg_vendor_json is not None:
        xdg_koopa = xdg_home / "koopa"
        xdg_koopa.mkdir(parents=True)
        (xdg_koopa / "vendor.json").write_text(json.dumps(xdg_vendor_json))
    script = (
        f'set -eu\n{_function_defs_only()}\nKOOPA_PREFIX="{tmp_path}"\nvendor_load\n{script_body}\n'
    )
    env = os.environ.copy()
    # A real '~/.config/koopa/vendor.json' on the host must never be
    # reachable here -- override, not inherit, XDG_CONFIG_HOME.
    env["XDG_CONFIG_HOME"] = str(xdg_home)
    result = subprocess.run(
        ["sh", "-c", script], capture_output=True, text=True, check=True, env=env
    )
    return result.stdout


_ANTI_DRIFT_VENDOR_JSON = {
    "enabled": True,
    "backend": "http",
    "http": {
        "base_url": "https://artifacts.example.com",
        "src_repo": "koopa-src",
        "remotes": {"github.com": "github-remote", ".gnu.org": "gnu-remote"},
    },
    "pull_priority": "vendor_first",
}


def test_bootstrap_vendor_src_url_matches_python(
    tmp_path: Path, monkeypatch: pytest.MonkeyPatch
) -> None:
    """Sh vendor_src_url() and Python koopa.vendor._http_src_url() agree byte-for-byte."""
    monkeypatch.setattr("koopa.prefix.koopa_prefix", lambda: str(tmp_path))
    from koopa.vendor import _http_src_url

    sh_output = _run_vendor_sh(
        "vendor_src_url perl perl-5.44.0.tar.gz", _ANTI_DRIFT_VENDOR_JSON, tmp_path
    )
    cfg = vendor_config()
    assert cfg is not None
    py_output = _http_src_url(cfg, "perl", "perl-5.44.0.tar.gz")

    assert sh_output.strip() == py_output


@pytest.mark.parametrize(
    "url",
    [
        "https://github.com/astral-sh/uv/releases/download/0.12.3/uv.tar.gz",
        "https://ftpmirror.gnu.org/gnu/xz/xz-5.8.3.tar.gz",
        "https://example.com/unmatched-host.tar.gz",
    ],
)
def test_bootstrap_vendor_rewrite_url_matches_python(
    url: str, tmp_path: Path, monkeypatch: pytest.MonkeyPatch
) -> None:
    """Sh vendor_rewrite_url() and Python koopa.vendor.vendor_rewrite_url() agree.

    Covers an exact host match, a '.suffix' host match, and an unmatched
    host (which prints nothing in sh, matching Python's None).
    """
    monkeypatch.setattr("koopa.prefix.koopa_prefix", lambda: str(tmp_path))

    sh_output = _run_vendor_sh(
        f'vendor_rewrite_url "{url}"', _ANTI_DRIFT_VENDOR_JSON, tmp_path
    ).strip()
    py_output = vendor_rewrite_url(url)

    assert sh_output == (py_output or "")


def test_bootstrap_and_python_agree_on_xdg_precedence(
    tmp_path: Path, monkeypatch: pytest.MonkeyPatch
) -> None:
    """Sh vendor_load() and Python vendor_config() apply the same XDG-first order.

    Both prefer '$XDG_CONFIG_HOME/koopa/vendor.json' over
    'etc/koopa/vendor.json' when both exist -- the regression this guards
    against is one side implementing the fallback but not the precedence.
    """
    xdg_json = {
        "enabled": True,
        "backend": "http",
        "http": {
            "base_url": "https://xdg.example.com",
            "src_repo": "koopa-src",
            "remotes": {"github.com": "github-remote", ".gnu.org": "gnu-remote"},
        },
        "pull_priority": "vendor_first",
    }
    monkeypatch.setattr("koopa.prefix.koopa_prefix", lambda: str(tmp_path))
    # Match _run_vendor_sh()'s own XDG_CONFIG_HOME so the Python-side
    # vendor_config() call below reads the same XDG file the sh subprocess did.
    monkeypatch.setenv("XDG_CONFIG_HOME", str(tmp_path / "xdg-empty"))
    from koopa.vendor import _http_src_url

    sh_output = _run_vendor_sh(
        "vendor_src_url perl perl-5.44.0.tar.gz",
        _ANTI_DRIFT_VENDOR_JSON,
        tmp_path,
        xdg_vendor_json=xdg_json,
    ).strip()
    cfg = vendor_config()
    assert cfg is not None
    py_output = _http_src_url(cfg, "perl", "perl-5.44.0.tar.gz")

    assert sh_output == py_output
    assert py_output.startswith("https://xdg.example.com/")


def test_vendor_sed_fallback_does_not_match_comment_line(tmp_path: Path) -> None:
    """The sed fallback parser never mistakes '_comment' prose for real keys.

    etc/koopa/vendor.json.example's '_comment' field contains the words
    "enabled" and "backend" in its prose ("Set 'enabled' to true and fill in
    your backend details."); an unanchored sed pattern would match that line
    before ever reaching the real "enabled"/"backend" keys. Uses the real
    example file's '_comment' text, but forces 'enabled' to true -- the
    shipped example defaults to disabled, which would make the parser return
    nothing and this test vacuously pass regardless of the anchoring bug.
    """
    example = json.loads((_REPO_ROOT / "etc" / "koopa" / "vendor.json.example").read_text())
    example["enabled"] = True
    vendor_json_path = tmp_path / "vendor.json"
    vendor_json_path.write_text(json.dumps(example, indent=2))
    script = f'set -eu\n{_function_defs_only()}\n_vendor_sed_fallback "{vendor_json_path}"\n'
    result = subprocess.run(["sh", "-c", script], capture_output=True, text=True, check=True)
    fields = dict(line.split("\t", 1) for line in result.stdout.splitlines() if line)

    assert fields["enabled"] == "1"
    assert fields["backend"] == "http"
    assert fields["pull_priority"] == "vendor_first"
    assert fields["src_repo"] == "generic-team-koopa-src"
