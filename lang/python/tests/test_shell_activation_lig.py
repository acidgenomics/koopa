"""Lig shell activation tests."""

import os
import shutil
import subprocess
from pathlib import Path

import pytest

_REPO = Path(__file__).resolve().parents[3]


def _supported_bash() -> str:
    for candidate in (shutil.which("bash"), str(_REPO / "bin/bash")):
        if not candidate or not os.access(candidate, os.X_OK):
            continue
        version = subprocess.run(
            [candidate, "-c", 'printf "%s %s" "${BASH_VERSINFO[0]}" "${BASH_VERSINFO[1]}"'],
            check=True,
            capture_output=True,
            text=True,
        )
        if tuple(map(int, version.stdout.split())) >= (4, 4):
            return candidate
    pytest.skip("Bash 4.4 or newer is not installed")


@pytest.mark.parametrize("lookup_succeeds", [True, False])
def test_lig_bash_pre_uses_running_shell_for_login_argv0(
    tmp_path: Path, lookup_succeeds: bool
) -> None:
    """Ghostty's login argv0 must not make Lig launch the account's Zsh."""
    bash = _supported_bash()
    prefix = tmp_path / "koopa"
    bin_dir = prefix / "bin"
    bin_dir.mkdir(parents=True)
    lig = bin_dir / "lig"
    lig.write_text(
        "#!/bin/sh\n"
        'case "$1" in\n'
        '  init) printf \'exec "$KOOPA_PREFIX/bin/lig" shell --shell "$BASH"\\n\' ;;\n'
        '  shell-path) test "$TEST_LOOKUP" = 1 || exit 1; printf \'%s\\n\' "$TEST_BASH" ;;\n'
        "  shell) printf 'LIG_SHELL=%s\\n' \"$3\" ;;\n"
        "esac\n"
    )
    lig.chmod(0o755)
    source = _REPO / "lang/bash/functions/activate/activate-lig.sh"
    env = {
        "HOME": str(tmp_path),
        "PATH": os.environ["PATH"],
        "SHELL": "/bin/zsh",
        "TERM": "xterm",
        "KOOPA_PREFIX": str(prefix),
        "XDG_CACHE_HOME": str(tmp_path / "cache"),
        "TEST_BASH": bash,
        "TEST_LOOKUP": "1" if lookup_succeeds else "0",
    }
    master, slave = os.openpty()
    try:
        subprocess.run(
            [
                bash,
                "-c",
                'exec -l "$1" --noprofile --norc -ic "$2"',
                "_",
                bash,
                f"source {source}; _koopa_activate_lig_pre; printf 'CONTINUED\\n'",
            ],
            env=env,
            stdin=slave,
            stdout=slave,
            stderr=slave,
            timeout=60,
            check=True,
        )
        output = os.read(master, 8192).decode()
    finally:
        os.close(master)
        os.close(slave)
    if lookup_succeeds:
        assert f"LIG_SHELL={bash}" in output
    else:
        assert "LIG_SHELL=" not in output
        assert "CONTINUED" in output


@pytest.mark.parametrize("shell", ["bash", "zsh"])
@pytest.mark.parametrize("nounset", [False, True], ids=["nounset-off", "nounset-on"])
def test_lig_post_activation_is_cached_and_respects_disable(
    shell: str,
    nounset: bool,
    tmp_path: Path,
) -> None:
    """Source Lig's post-init snippet only when enabled, and cache it."""
    shell_path = _supported_bash() if shell == "bash" else shutil.which(shell)
    if shell_path is None:
        pytest.skip(f"{shell} is not installed")

    koopa_prefix = tmp_path / "koopa"
    bin_dir = koopa_prefix / "bin"
    bin_dir.mkdir(parents=True)
    lig = bin_dir / "lig"
    lig.write_text(
        "#!/bin/sh\n"
        "printf 'called\\n' >> \"$LIG_TEST_LOG\"\n"
        "printf 'export LIG_TEST_VALUE=loaded\\n'\n"
    )
    lig.chmod(0o755)
    shell_functions = _REPO / "lang" / shell / "functions/activate/activate-lig.sh"

    env = os.environ.copy()
    env["KOOPA_PREFIX"] = str(koopa_prefix)
    env["XDG_CACHE_HOME"] = str(tmp_path / "cache")
    env["LIG_TEST_LOG"] = str(tmp_path / "lig-calls")
    env["LIG_DISABLE"] = "1"
    nounset_option = "-u" if nounset else "+u"
    command = (
        f"set {nounset_option}; "
        f"source {shell_functions!s}; "
        "_koopa_activate_lig_post || exit $?; "
        f"[[ -o nounset ]] {'||' if nounset else '&&'} exit 99; "
        "printf '%s\\n' \"${LIG_TEST_VALUE:-disabled}\""
    )
    shell_args = (
        [shell_path, "--noprofile", "--norc", "-ic", command]
        if shell == "bash"
        else [shell_path, "-f", "-ic", command]
    )
    disabled = subprocess.run(
        shell_args,
        check=True,
        capture_output=True,
        text=True,
        env=env,
    )
    assert disabled.stdout.rstrip().endswith("disabled")
    assert not Path(env["LIG_TEST_LOG"]).exists()

    env.pop("LIG_DISABLE")
    enabled = subprocess.run(
        shell_args,
        check=True,
        capture_output=True,
        text=True,
        env=env,
    )
    assert enabled.stdout.rstrip().endswith("loaded")
    assert Path(env["LIG_TEST_LOG"]).read_text().splitlines() == ["called"]

    cached = subprocess.run(
        shell_args,
        check=True,
        capture_output=True,
        text=True,
        env=env,
    )
    assert cached.stdout.rstrip().endswith("loaded")
    assert Path(env["LIG_TEST_LOG"]).read_text().splitlines() == ["called"]
