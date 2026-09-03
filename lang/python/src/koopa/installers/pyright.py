"""Install pyright, then verify the npm-backed engine actually starts.

pyright ships on PyPI as a thin shim (the ``pyright-python`` package) that
downloads the real type-checking engine from npm on first run. koopa's shell
activation forces ``PYRIGHT_PYTHON_FORCE_VERSION=latest`` (see
``lang/*/functions/activate/activate-pyright.sh``), so that npm resolve runs
against whatever Node/npm koopa currently has on ``PATH``, on every fresh
cache -- not just once at pin time.

A broken Node build corrupts that resolve silently. For example,
conda-forge's ``node`` 26.8.0 packaged an upstream Node.js build that
misreports its own version as an alpha pre-release; npm's engine check then
prints a warning whose own version number gets mis-parsed by pyright-python
as "the latest pyright version", and the follow-up ``npm install`` fails on
a version that does not exist. The pip install itself still succeeds, so
this class of breakage previously surfaced only the first time a user ran
``pyright``, not at install time.

Run ``pyright --version`` once after install, with the same env force koopa's
shell activation applies, so a broken engine fails the install instead.
"""

import os
import subprocess

from koopa.install import install_python_package
from koopa.installers._args import get_dict, get_list, get_str, parse_passthrough


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install pyright, then smoke-test the npm-backed engine."""
    kwargs = parse_passthrough(passthrough_args)
    extra = get_list(kwargs, "extra_packages")
    build_env = get_dict(kwargs, "build_env")
    install_python_package(
        name=get_str(kwargs, "name", name),
        version=version,
        prefix=prefix,
        pip_name=get_str(kwargs, "pip_name"),
        egg_name=get_str(kwargs, "egg_name"),
        python_version=get_str(kwargs, "python_version"),
        extra_packages=extra or None,
        no_binary=get_str(kwargs, "no_binary") == "true",
        build_env=build_env or None,
    )
    _verify(prefix)


def _verify(prefix: str) -> None:
    """Run ``pyright --version``, forcing the 'latest' npm engine resolve.

    Raises with npm's own captured output on failure, since a bare
    ``CalledProcessError`` would hide the actual root cause (an npm warning
    or a version-not-found error) from the install failure message.
    """
    binary = os.path.join(prefix, "bin", "pyright")
    env = {**os.environ, "PYRIGHT_PYTHON_FORCE_VERSION": "latest"}
    result = subprocess.run(
        [binary, "--version"],
        capture_output=True,
        text=True,
        env=env,
        check=False,
    )
    if result.returncode != 0 or not result.stdout.strip().startswith("pyright "):
        msg = f"'pyright --version' failed after install:\n{result.stdout}{result.stderr}"
        raise RuntimeError(msg)
