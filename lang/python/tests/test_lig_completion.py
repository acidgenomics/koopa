"""Lig completion spec integration tests."""

import os
import shutil
import subprocess
from pathlib import Path

import pytest
from koopa.cli_develop import _DEVELOP_HANDLERS
from koopa.generate_completion import _generate_lig_completion, _load_app_tree


def test_lig_spec_suggests_commands_and_apps(tmp_path: Path) -> None:
    """Lig should expose develop commands, app names, and install options."""
    lig = shutil.which("lig")
    if lig is None:
        pytest.skip("Lig is not installed")
    specs = tmp_path / "lig" / "specs"
    specs.mkdir(parents=True)
    spec = specs / "koopa.json"
    spec.write_text(
        _generate_lig_completion(
            _load_app_tree(),
            sorted(_DEVELOP_HANDLERS),
            {"develop/check-app-versions": ["--help", "--json"]},
        )
    )
    root = Path(__file__).resolve().parents[3]
    env = {
        **os.environ,
        "KOOPA_PREFIX": str(root),
        "PATH": f"{root / 'bin'}{os.pathsep}{os.environ.get('PATH', '')}",
        "XDG_CONFIG_HOME": str(tmp_path),
    }
    subprocess.run([lig, "specs", "check", str(spec)], env=env, check=True, capture_output=True)

    def complete(line: str) -> str:
        return subprocess.run(
            [lig, "complete", line], env=env, check=True, capture_output=True, text=True
        ).stdout

    assert "check-app-versions" in complete("koopa develop check-a")
    assert "--json" in complete("koopa develop check-app-versions --")
    assert "python" in complete("koopa install python")
    assert "--no-dependencies" in complete("koopa install --no-")
    assert "aws" in complete("koopa app aw")
    assert "--version" in complete("koopa --ver")
    assert "color-mode" in complete("koopa configure user color-m")
