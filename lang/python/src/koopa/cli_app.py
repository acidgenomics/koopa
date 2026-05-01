"""Dispatch table for ``koopa app`` subcommands.

Replaces the 415-line ``_koopa_cli_app`` Bash function. Maps hierarchical
command keys (e.g. ``aws-batch-list-jobs``) to Python callables where
available, falling back to Bash function dispatch for the rest.
"""

from __future__ import annotations

import os
import shlex
import shutil
import subprocess
import sys
from typing import Any

from koopa.prefix import bash_prefix


def _run_bash_function(key: str, *args: str) -> None:
    """Fall back to calling a Bash function by name."""
    bash = shutil.which("bash")
    if bash is None:
        msg = "Bash is required."
        raise RuntimeError(msg)
    header = os.path.join(bash_prefix(), "include", "header.sh")
    fun = "_koopa_" + key.replace("-", "_")
    parts = [f"source '{header}'", fun]
    if args:
        parts[1] = f"{fun} {shlex.join(args)}"
    cmd = "; ".join(parts)
    subprocess.run(
        [
            bash,
            "--noprofile",
            "--norc",
            "-o",
            "errexit",
            "-o",
            "errtrace",
            "-o",
            "nounset",
            "-o",
            "pipefail",
            "-c",
            cmd,
        ],
        check=True,
    )


_APP_TREE: dict[str, Any] = {
    "aws": {
        "batch": {
            "fetch-and-run": "aws-batch-fetch-and-run",
            "list-jobs": "aws-batch-list-jobs",
        },
        "codecommit": {
            "list-repositories": "aws-codecommit-list-repositories",
        },
        "ec2": {
            "instance-id": "aws-ec2-instance-id",
            "list-running-instances": "aws-ec2-list-running-instances",
            "map-instance-ids-to-names": "aws-ec2-map-instance-ids-to-names",
            "stop": "aws-ec2-stop",
        },
        "ecr": {
            "login-public": "aws-ecr-login-public",
            "login-private": "aws-ecr-login-private",
        },
        "s3": {
            "delete-markers": "aws-s3-delete-markers",
            "delete-versioned-glacier-objects": "aws-s3-delete-versioned-glacier-objects",
            "delete-versioned-objects": "aws-s3-delete-versioned-objects",
            "dot-clean": "aws-s3-dot-clean",
            "find": "aws-s3-find",
            "list-large-files": "aws-s3-list-large-files",
            "ls": "aws-s3-ls",
            "mv-to-parent": "aws-s3-mv-to-parent",
            "sync": "aws-s3-sync",
        },
    },
    "bioconda": {
        "autobump-recipe": "bioconda-autobump-recipe",
    },
    "bowtie2": {
        "align": {
            "paired-end": "bowtie2-align-paired-end",
        },
        "index": "bowtie2-index",
    },
    "brew": {
        "cleanup": "brew-cleanup",
        "dump-brewfile": "brew-dump-brewfile",
        "outdated": "brew-outdated",
        "reset-core-repo": "brew-reset-core-repo",
        "reset-permissions": "brew-reset-permissions",
        "uninstall-all-brews": "brew-uninstall-all-brews",
        "upgrade-brews": "brew-upgrade-brews",
        "version": "brew-version",
    },
    "conda": {
        "create-env": "conda-create-env",
        "remove-env": "conda-remove-env",
    },
    "docker": {
        "build": "docker-build",
        "build-all-tags": "docker-build-all-tags",
        "prune-all-images": "docker-prune-all-images",
        "prune-old-images": "docker-prune-old-images",
        "remove": "docker-remove",
        "run": "docker-run",
    },
    "ftp": {
        "mirror": "ftp-mirror",
    },
    "git": {
        "pull": "git-pull",
        "push-submodules": "git-push-submodules",
        "rename-master-to-main": "git-rename-master-to-main",
        "reset": "git-reset",
        "reset-fork-to-upstream": "git-reset-fork-to-upstream",
        "rm-submodule": "git-rm-submodule",
        "rm-untracked": "git-rm-untracked",
    },
    "gpg": {
        "prompt": "gpg-prompt",
        "reload": "gpg-reload",
        "restart": "gpg-restart",
    },
    "hisat2": {
        "align": {
            "paired-end": "hisat2-align-paired-end",
            "single-end": "hisat2-align-single-end",
        },
        "index": "hisat2-index",
    },
    "jekyll": {
        "serve": "jekyll-serve",
    },
    "kallisto": {
        "index": "kallisto-index",
        "quant": {
            "paired-end": "kallisto-quant-paired-end",
            "single-end": "kallisto-quant-single-end",
        },
    },
    "md5sum": {
        "check-to-new-md5-file": "md5sum-check-to-new-md5-file",
    },
    "miso": {
        "index": "miso-index",
        "run": "miso-run",
    },
    "r": {
        "bioconda-check": "r-bioconda-check",
        "check": "r-check",
    },
    "rmats": "rmats",
    "rnaeditingindexer": "rnaeditingindexer",
    "rsem": {
        "index": "rsem-index",
        "quant": {
            "bam": "rsem-quant-bam",
        },
    },
    "salmon": {
        "detect-fastq-library-type": "salmon-detect-fastq-library-type",
        "index": "salmon-index",
        "quant": {
            "bam": "salmon-quant-bam",
            "paired-end": "salmon-quant-paired-end",
            "single-end": "salmon-quant-single-end",
        },
    },
    "sra": {
        "download-accession-list": "sra-download-accession-list",
        "download-run-info-table": "sra-download-run-info-table",
        "fastq-dump": "sra-fastq-dump",
        "prefetch": "sra-prefetch",
    },
    "ssh": {
        "generate-key": "ssh-generate-key",
    },
    "star": {
        "align": {
            "paired-end": "star-align-paired-end",
            "single-end": "star-align-single-end",
        },
        "index": "star-index",
    },
    "wget": {
        "recursive": "wget-recursive",
    },
}


def _resolve_tree(
    remainder: list[str],
) -> tuple[str, list[str]]:
    """Walk the dispatch tree, returning (function_key, leftover_args)."""
    node: Any = _APP_TREE
    consumed = 0
    last_key: str = ""
    for i, token in enumerate(remainder):
        if not isinstance(node, dict) or token not in node:
            break
        node = node[token]
        consumed = i + 1
        if isinstance(node, str):
            last_key = node
            consumed = i + 1
            break
    if not last_key:
        if isinstance(node, str):
            last_key = node
        else:
            msg = f"Unknown app command: koopa app {' '.join(remainder)}"
            raise SystemExit(msg)
    return last_key, remainder[consumed:]


def _handle_docker_build_all_tags(args: list[str]) -> None:
    import argparse

    parser = argparse.ArgumentParser(
        prog="koopa app docker build-all-tags",
    )
    parser.add_argument("--local", required=True)
    parser.add_argument("--remote", required=True)
    parsed = parser.parse_args(args)
    from koopa.shell.docker import build_all_tags

    build_all_tags(local=parsed.local, remote=parsed.remote)


_PYTHON_HANDLERS: dict[str, Any] = {
    "docker-build-all-tags": _handle_docker_build_all_tags,
}


def handle_app(remainder: list[str]) -> None:
    """Dispatch ``koopa app ...`` commands."""
    if not remainder:
        print("Error: no app command specified.", file=sys.stderr)
        sys.exit(1)
    if remainder[-1] in ("--help", "-h"):
        from koopa.cli_help import show_man_page

        show_man_page("app", *remainder[:-1])
        return
    key, args = _resolve_tree(remainder)
    handler = _PYTHON_HANDLERS.get(key)
    if handler is not None:
        handler(args)
        return
    _run_bash_function(key, *args)
