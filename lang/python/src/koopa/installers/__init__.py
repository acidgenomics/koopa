"""Installer registry for Python-native app installers.

Maps app names to Python modules containing a ``main()`` function that
performs the installation. Apps not in the registry fall through to the
existing Bash subshell installer path.
"""

from __future__ import annotations

import importlib
from collections.abc import Callable

_INSTALLER_MODULE = "koopa.installers"

PYTHON_INSTALLERS: dict[str, str] = {
    # -- conda-package ---------------------------------------------------
    "autodock": f"{_INSTALLER_MODULE}._conda",
    "bamtools": f"{_INSTALLER_MODULE}._conda",
    "bash-language-server": f"{_INSTALLER_MODULE}._conda",
    "bat": f"{_INSTALLER_MODULE}._conda",
    "bedtools": f"{_INSTALLER_MODULE}._conda",
    "bioawk": f"{_INSTALLER_MODULE}._conda",
    "bioconda-utils": f"{_INSTALLER_MODULE}._conda",
    "blast": f"{_INSTALLER_MODULE}._conda",
    "bottom": f"{_INSTALLER_MODULE}._conda",
    "bowtie2": f"{_INSTALLER_MODULE}._conda",
    "broot": f"{_INSTALLER_MODULE}._conda",
    "btop": f"{_INSTALLER_MODULE}._conda",
    "bustools": f"{_INSTALLER_MODULE}._conda",
    "csvtk": f"{_INSTALLER_MODULE}._conda",
    "deeptools": f"{_INSTALLER_MODULE}._conda",
    "difftastic": f"{_INSTALLER_MODULE}._conda",
    "direnv": f"{_INSTALLER_MODULE}._conda",
    "entrez-direct": f"{_INSTALLER_MODULE}._conda",
    "eza": f"{_INSTALLER_MODULE}._conda",
    "fastqc": f"{_INSTALLER_MODULE}._conda",
    "fd-find": f"{_INSTALLER_MODULE}._conda",
    "ffmpeg": f"{_INSTALLER_MODULE}._conda",
    "ffq": f"{_INSTALLER_MODULE}._conda",
    "fgbio": f"{_INSTALLER_MODULE}._conda",
    "fish": f"{_INSTALLER_MODULE}._conda",
    "fq": f"{_INSTALLER_MODULE}._conda",
    "fqtk": f"{_INSTALLER_MODULE}._conda",
    "fzf": f"{_INSTALLER_MODULE}._conda",
    "genomepy": f"{_INSTALLER_MODULE}._conda",
    "gffutils": f"{_INSTALLER_MODULE}._conda",
    "gget": f"{_INSTALLER_MODULE}._conda",
    "gitui": f"{_INSTALLER_MODULE}._conda",
    "grex": f"{_INSTALLER_MODULE}._conda",
    "hisat2": f"{_INSTALLER_MODULE}._conda",
    "htseq": f"{_INSTALLER_MODULE}._conda",
    "hyperfine": f"{_INSTALLER_MODULE}._conda",
    "k9s": f"{_INSTALLER_MODULE}._conda",
    "luigi": f"{_INSTALLER_MODULE}._conda",
    "mamba": f"{_INSTALLER_MODULE}._conda",
    "mcfly": f"{_INSTALLER_MODULE}._conda",
    "mdcat": f"{_INSTALLER_MODULE}._conda",
    "misopy": f"{_INSTALLER_MODULE}._conda",
    "nanopolish": f"{_INSTALLER_MODULE}._conda",
    "nushell": f"{_INSTALLER_MODULE}._conda",
    "procs": f"{_INSTALLER_MODULE}._conda",
    "radian": f"{_INSTALLER_MODULE}._conda",
    "ranger-fm": f"{_INSTALLER_MODULE}._conda",
    "rclone": f"{_INSTALLER_MODULE}._conda",
    "ripgrep": f"{_INSTALLER_MODULE}._conda",
    "ripgrep-all": f"{_INSTALLER_MODULE}._conda",
    "rsem": f"{_INSTALLER_MODULE}._conda",
    "sambamba": f"{_INSTALLER_MODULE}._conda",
    "samtools": f"{_INSTALLER_MODULE}._conda",
    "sd": f"{_INSTALLER_MODULE}._conda",
    "seqkit": f"{_INSTALLER_MODULE}._conda",
    "shellcheck": f"{_INSTALLER_MODULE}._conda",
    "snakemake": f"{_INSTALLER_MODULE}._conda",
    "sox": f"{_INSTALLER_MODULE}._conda",
    "star-fusion": f"{_INSTALLER_MODULE}._conda",
    "starship": f"{_INSTALLER_MODULE}._conda",
    "subread": f"{_INSTALLER_MODULE}._conda",
    "tealdeer": f"{_INSTALLER_MODULE}._conda",
    "tokei": f"{_INSTALLER_MODULE}._conda",
    "tuc": f"{_INSTALLER_MODULE}._conda",
    "umis": f"{_INSTALLER_MODULE}._conda",
    "xsv": f"{_INSTALLER_MODULE}._conda",
    "zellij": f"{_INSTALLER_MODULE}._conda",
    "zenith": f"{_INSTALLER_MODULE}._conda",
    "zoxide": f"{_INSTALLER_MODULE}._conda",
    "zsh": f"{_INSTALLER_MODULE}._conda",
    # -- python-package --------------------------------------------------
    "apache-airflow": f"{_INSTALLER_MODULE}._python_pkg",
    "autoflake": f"{_INSTALLER_MODULE}._python_pkg",
    "azure-cli": f"{_INSTALLER_MODULE}._python_pkg",
    "bandit": f"{_INSTALLER_MODULE}._python_pkg",
    "black": f"{_INSTALLER_MODULE}._python_pkg",
    "bpytop": f"{_INSTALLER_MODULE}._python_pkg",
    "bumpver": f"{_INSTALLER_MODULE}._python_pkg",
    "commitizen": f"{_INSTALLER_MODULE}._python_pkg",
    "csvkit": f"{_INSTALLER_MODULE}._python_pkg",
    "flake8": f"{_INSTALLER_MODULE}._python_pkg",
    "gentropy": f"{_INSTALLER_MODULE}._python_pkg",
    "git-filter-repo": f"{_INSTALLER_MODULE}._python_pkg",
    "glances": f"{_INSTALLER_MODULE}._python_pkg",
    "httpie": f"{_INSTALLER_MODULE}._python_pkg",
    "httpx": f"{_INSTALLER_MODULE}._python_pkg",
    "huggingface-hub": f"{_INSTALLER_MODULE}._python_pkg",
    "ipython": f"{_INSTALLER_MODULE}._python_pkg",
    "isort": f"{_INSTALLER_MODULE}._python_pkg",
    "jupyterlab": f"{_INSTALLER_MODULE}._python_pkg",
    "latch": f"{_INSTALLER_MODULE}._python_pkg",
    "marimo": f"{_INSTALLER_MODULE}._python_pkg",
    "meson": f"{_INSTALLER_MODULE}._python_pkg",
    "mosaicml-cli": f"{_INSTALLER_MODULE}._python_pkg",
    "multiqc": f"{_INSTALLER_MODULE}._python_pkg",
    "mutagen": f"{_INSTALLER_MODULE}._python_pkg",
    "mypy": f"{_INSTALLER_MODULE}._python_pkg",
    "pipx": f"{_INSTALLER_MODULE}._python_pkg",
    "poetry": f"{_INSTALLER_MODULE}._python_pkg",
    "py-spy": f"{_INSTALLER_MODULE}._python_pkg",
    "pycodestyle": f"{_INSTALLER_MODULE}._python_pkg",
    "pyflakes": f"{_INSTALLER_MODULE}._python_pkg",
    "pygments": f"{_INSTALLER_MODULE}._python_pkg",
    "pylint": f"{_INSTALLER_MODULE}._python_pkg",
    "pyrefly": f"{_INSTALLER_MODULE}._python_pkg",
    "pyright": f"{_INSTALLER_MODULE}._python_pkg",
    "pytest": f"{_INSTALLER_MODULE}._python_pkg",
    "ruff": f"{_INSTALLER_MODULE}._python_pkg",
    "ruff-lsp": f"{_INSTALLER_MODULE}._python_pkg",
    "scalene": f"{_INSTALLER_MODULE}._python_pkg",
    "scanpy": f"{_INSTALLER_MODULE}._python_pkg",
    "scons": f"{_INSTALLER_MODULE}._python_pkg",
    "shyaml": f"{_INSTALLER_MODULE}._python_pkg",
    "snakefmt": f"{_INSTALLER_MODULE}._python_pkg",
    "sphinx": f"{_INSTALLER_MODULE}._python_pkg",
    "sqlfluff": f"{_INSTALLER_MODULE}._python_pkg",
    "streamlit": f"{_INSTALLER_MODULE}._python_pkg",
    "tqdm": f"{_INSTALLER_MODULE}._python_pkg",
    "tryceratops": f"{_INSTALLER_MODULE}._python_pkg",
    "ty": f"{_INSTALLER_MODULE}._python_pkg",
    "visidata": f"{_INSTALLER_MODULE}._python_pkg",
    "vulture": f"{_INSTALLER_MODULE}._python_pkg",
    "yamllint": f"{_INSTALLER_MODULE}._python_pkg",
    "yapf": f"{_INSTALLER_MODULE}._python_pkg",
    "yt-dlp": f"{_INSTALLER_MODULE}._python_pkg",
    # -- gnu-app ---------------------------------------------------------
    "gperf": f"{_INSTALLER_MODULE}._gnu",
    "m4": f"{_INSTALLER_MODULE}._gnu",
    # -- node-package ----------------------------------------------------
    "aws-azure-login": f"{_INSTALLER_MODULE}._node_pkg",
    "gtop": f"{_INSTALLER_MODULE}._node_pkg",
    "markdownlint-cli": f"{_INSTALLER_MODULE}._node_pkg",
    # -- ruby-package ----------------------------------------------------
    "bashcov": f"{_INSTALLER_MODULE}._ruby_pkg",
    "colorls": f"{_INSTALLER_MODULE}._ruby_pkg",
    "rmate": f"{_INSTALLER_MODULE}._ruby_pkg",
    "ronn-ng": f"{_INSTALLER_MODULE}._ruby_pkg",
    # -- rust-package ----------------------------------------------------
    "bandwhich": f"{_INSTALLER_MODULE}._rust_pkg",
    "hexyl": f"{_INSTALLER_MODULE}._rust_pkg",
}


def has_python_installer(name: str) -> bool:
    """Check if app has a Python-native installer."""
    return name in PYTHON_INSTALLERS


def get_python_installer(
    name: str,
) -> Callable[..., None]:
    """Dynamically import and return the installer's ``main`` function."""
    module_path = PYTHON_INSTALLERS[name]
    mod = importlib.import_module(module_path)
    return mod.main  # type: ignore[attr-defined]
