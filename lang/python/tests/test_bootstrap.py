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


def test_bootstrap_cpu_count_respects_slurm_allocation(tmp_path: Path) -> None:
    """Regression: a stale/oversized KOOPA_CPU_COUNT must not win over Slurm.

    Observed on a real Slurm GPU node: KOOPA_CPU_COUNT was inherited as 96
    (the node's total core count, from a login-node activation propagated by
    srun) while SLURM_CPUS_ON_NODE correctly reported the 1-CPU allocation.
    Trusting KOOPA_CPU_COUNT there made 'make --jobs=96' run on one core.
    """
    script = f'set -eu\n{_function_defs_only()}\nKOOPA_PREFIX="{tmp_path}"\ncpu_count\n'
    env = os.environ.copy()
    env["SLURM_CPUS_ON_NODE"] = "1"
    env["KOOPA_CPU_COUNT"] = "96"
    env.pop("SLURM_CPUS_PER_TASK", None)
    result = subprocess.run(
        ["sh", "-c", script], capture_output=True, text=True, check=True, env=env
    )
    assert result.stdout.strip() == "1"


def test_bootstrap_cpu_count_rejects_malformed_slurm_value(tmp_path: Path) -> None:
    """A malformed Slurm variable must fall through, never reach 'make --jobs'.

    Simulates Slurm's compressed multi-node form (e.g. '4(x2)', the real shape
    of SLURM_JOB_CPUS_PER_NODE) landing on a name cpu_count() does read.
    """
    script = f'set -eu\n{_function_defs_only()}\nKOOPA_PREFIX="{tmp_path}"\ncpu_count\n'
    env = os.environ.copy()
    env["SLURM_CPUS_PER_TASK"] = "4(x2)"
    env["SLURM_CPUS_ON_NODE"] = "2"
    env.pop("KOOPA_CPU_COUNT", None)
    result = subprocess.run(
        ["sh", "-c", script], capture_output=True, text=True, check=True, env=env
    )
    assert result.stdout.strip() == "2"


def test_bootstrap_uv_fast_path_is_unconditional() -> None:
    """Regression: the uv fast path must run on every host, not just some.

    has_firewall() previously vetoed the fast path whenever SSL_CERT_FILE was
    set to koopa's own CA bundle sitting outside $KOOPA_PREFIX -- exactly what
    koopa's own shell activation exports -- forcing a source compile even
    when the CDN was reachable. Measured cost on a real host: 16m42s.
    install_python_uv() already fails cleanly and falls back to a source
    build on any real failure, so the attempt itself must never be gated.
    """
    text = _BOOTSTRAP_SH.read_text()
    assert "has_firewall" not in text
    after_marker = text[text.index("__kvar_build_ok=0") :]
    before_then = after_marker[: after_marker.index("\n    then\n")]
    code_lines = [
        line.strip()
        for line in before_then.splitlines()
        if line.strip() and not line.strip().startswith("#")
    ]
    assert code_lines[0] == "__kvar_build_ok=0"
    assert code_lines[1] == "if (", (
        f"expected the uv fast path to open unconditionally right after"
        f" '__kvar_build_ok=0', found: {code_lines[1]!r}"
    )


def test_bootstrap_has_no_use_sudo_flag() -> None:
    """Regression: 'koopa update' must never trigger a sudo prompt on a healthy install.

    bootstrap.sh used to decide it needed sudo by testing write permission on
    PREFIX's *parent* -- which is never writable for a shared '/opt/koopa'
    install, since the bootstrap prefix ('/opt/koopa-bootstrap') sits next to
    it under root-owned '/opt'. That made every bootstrap rebuild during
    'koopa update' prompt for a password even though the user owns the
    prefix itself. 'stage_init'/'stage_commit' swap PREFIX's *children*
    in place instead, which only needs PREFIX to be writable -- true for any
    install the user actually owns. Asserts the old flag is gone outright,
    rather than asserting behavior that could silently regress back to it.
    """
    text = _BOOTSTRAP_SH.read_text()
    assert "__kvar_use_sudo" not in text


def _stage_script(prefix: Path, extra: str = "") -> str:
    return f'set -eu\n{_function_defs_only()}\nPREFIX="{prefix}"\n{extra}\n'


def test_stage_init_prefers_rename_swap_when_parent_is_writable(tmp_path: Path) -> None:
    """A writable parent stages beside PREFIX and never touches sudo."""
    prefix = tmp_path / "koopa-bootstrap"
    script = _stage_script(
        prefix,
        "stage_init\n"
        "printf 'INPLACE\\t%s\\n' \"$__kvar_inplace\"\n"
        "printf 'DESTDIR\\t%s\\n' \"$__kvar_destdir\"\n",
    )
    result = subprocess.run(["sh", "-c", script], capture_output=True, text=True, check=True)
    fields = dict(line.split("\t", 1) for line in result.stdout.splitlines() if line)
    assert fields["INPLACE"] == "0"
    assert fields["DESTDIR"].startswith(f"{prefix}.staging.")


def test_stage_init_and_commit_swap_in_place_when_parent_is_not_writable(
    tmp_path: Path,
) -> None:
    """A non-writable parent with an existing, user-owned prefix swaps in place.

    No sudo call is needed or made: swapping PREFIX's children requires
    write permission on PREFIX itself, which the owning user already has,
    not on PREFIX's parent.
    """
    if os.geteuid() == 0:
        pytest.skip("root bypasses the permission bits this test relies on")
    parent = tmp_path / "opt"
    prefix = parent / "koopa-bootstrap"
    prefix.mkdir(parents=True)
    (prefix / "OLD_FILE").write_text("stale\n")
    os.chmod(parent, 0o555)
    try:
        script = _stage_script(
            prefix,
            "stage_init\n"
            "printf 'INPLACE\\t%s\\n' \"$__kvar_inplace\"\n"
            'mkdir -p "${__kvar_destdir}${PREFIX}"\n'
            'touch "${__kvar_destdir}${PREFIX}/NEW_FILE"\n'
            "stage_commit\n",
        )
        result = subprocess.run(["sh", "-c", script], capture_output=True, text=True, check=True)
    finally:
        os.chmod(parent, 0o755)
    fields = dict(line.split("\t", 1) for line in result.stdout.splitlines() if line)
    assert fields["INPLACE"] == "1"
    entries = {p.name for p in prefix.iterdir()}
    assert entries == {"NEW_FILE"}
    assert not (prefix / "OLD_FILE").exists()


def test_stage_init_takes_ownership_via_sudo_on_first_create(tmp_path: Path) -> None:
    """A non-writable parent with no existing prefix takes ownership once via sudo.

    This is the one case a fresh shared install still needs a single sudo
    call for -- everything after it, including every later 'koopa update',
    runs unprivileged against the now user-owned prefix.
    """
    if os.geteuid() == 0:
        pytest.skip("root bypasses the permission bits this test relies on")
    parent = tmp_path / "opt"
    parent.mkdir()
    prefix = parent / "koopa-bootstrap"
    os.chmod(parent, 0o555)
    sudo_log = tmp_path / "sudo.log"
    stub = f"""
sudo() {{
    printf 'SUDO\\t%s\\n' "$*" >> "{sudo_log}"
    return 0
}}
"""
    try:
        script = _stage_script(
            prefix,
            f"{stub}\nstage_init\nprintf 'INPLACE\\t%s\\n' \"$__kvar_inplace\"\n",
        )
        result = subprocess.run(["sh", "-c", script], capture_output=True, text=True, check=True)
    finally:
        os.chmod(parent, 0o755)
    fields = dict(line.split("\t", 1) for line in result.stdout.splitlines() if line)
    assert fields["INPLACE"] == "1"
    calls = sudo_log.read_text().splitlines()
    assert len(calls) == 2
    assert calls[0].split("\t", 1)[1].startswith("mkdir")
    assert calls[1].split("\t", 1)[1].startswith("chown")


def test_stage_move_children_moves_dotfiles_and_skips_given_paths(tmp_path: Path) -> None:
    """Moves every top-level entry including dotfiles, except the ones told to skip."""
    src = tmp_path / "src"
    dst = tmp_path / "dst"
    src.mkdir()
    dst.mkdir()
    (src / "regular").write_text("a\n")
    (src / ".dotfile").write_text("b\n")
    skip_dir = src / ".skip-me"
    skip_dir.mkdir()
    script = f'set -eu\n{_function_defs_only()}\nstage_move_children "{src}" "{dst}" "{skip_dir}"\n'
    subprocess.run(["sh", "-c", script], capture_output=True, text=True, check=True)
    assert {p.name for p in dst.iterdir()} == {"regular", ".dotfile"}
    assert {p.name for p in src.iterdir()} == {".skip-me"}


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
