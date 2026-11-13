"""Copilot shell activation tests."""

import os
import shutil
import subprocess
from pathlib import Path

import pytest

_REPO = Path(__file__).resolve().parents[3]


@pytest.mark.parametrize("shell", ["sh", "bash", "zsh"])
@pytest.mark.parametrize("cached", [False, True], ids=["source", "cached"])
@pytest.mark.parametrize("bucket_state", ["vault", "directory", "unset", "noninteractive"])
def test_copilot_activation(tmp_path: Path, shell: str, cached: bool, bucket_state: str) -> None:
    """Grant only the vault and forward arguments without affecting non-interactive shells."""
    executable = shutil.which(shell)
    if executable is None:
        pytest.skip(f"{shell} is not installed")
    prefix = tmp_path / "koopa"
    bin_dir = prefix / "bin"
    bin_dir.mkdir(parents=True)
    stub = bin_dir / "copilot"
    stub.write_text("#!/bin/sh\nprintf '%s\\n' \"$@\"\n")
    stub.chmod(0o755)
    bucket = tmp_path / "vault with spaces"
    bucket.mkdir()
    if bucket_state in ("vault", "noninteractive"):
        (bucket / ".obsidian").mkdir()
    env = {**os.environ, "KOOPA_PREFIX": str(prefix), "PATH": str(bin_dir)}
    if bucket_state == "unset":
        env.pop("KOOPA_BUCKET", None)
    else:
        env["KOOPA_BUCKET"] = str(bucket)
    source = (
        _REPO / "lang" / shell / "include/functions.sh"
        if cached
        else _REPO / "lang" / shell / "functions/activate/activate-copilot-cli.sh"
    )
    interactive_status = 1 if bucket_state == "noninteractive" else 0
    result = subprocess.run(
        [
            executable,
            "-c",
            '. "$1"; shift; '
            f"_koopa_is_interactive() {{ return {interactive_status}; }}; "
            '_koopa_activate_copilot_cli; printf "UPDATE=%s\\n" "$COPILOT_AUTO_UPDATE"; '
            'copilot "$@"',
            "test-launcher",
            str(source),
            "--resume",
            "session with spaces",
        ],
        env=env,
        capture_output=True,
        check=True,
        text=True,
    )
    expected = ["UPDATE=false", "--resume", "session with spaces"]
    if bucket_state == "vault":
        expected[1:1] = ["--add-dir", str(bucket)]
    assert result.stdout.splitlines() == expected
