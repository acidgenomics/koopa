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
    "current": {
        "aws-cli-version": "current-aws-cli-version",
        "bioconductor-version": "current-bioconductor-version",
        "conda-package-version": "current-conda-package-version",
        "ensembl-version": "current-ensembl-version",
        "flybase-version": "current-flybase-version",
        "gencode-version": "current-gencode-version",
        "git-version": "current-git-version",
        "github-release-version": "current-github-release-version",
        "github-tag-version": "current-github-tag-version",
        "gnu-ftp-version": "current-gnu-ftp-version",
        "google-cloud-sdk-version": "current-google-cloud-sdk-version",
        "latch-version": "current-latch-version",
        "pypi-package-version": "current-pypi-package-version",
        "python-version": "current-python-version",
        "refseq-version": "current-refseq-version",
        "wormbase-version": "current-wormbase-version",
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
        "configure-environ": "r-configure-environ",
        "configure-java": "r-configure-java",
        "configure-ldpaths": "r-configure-ldpaths",
        "configure-makevars": "r-configure-makevars",
        "copy-files-into-etc": "r-copy-files-into-etc",
        "gfortran-libs": "r-gfortran-libs",
        "install-packages-in-site-library": "r-install-packages-in-site-library",
        "migrate-non-base-packages": "r-migrate-non-base-packages",
        "package-version": "r-package-version",
        "paste-to-vector": "r-paste-to-vector",
        "remove-packages-in-system-library": "r-remove-packages-in-system-library",
        "script": "r-script",
        "shiny-run-app": "r-shiny-run-app",
        "system-packages-non-base": "r-system-packages-non-base",
        "version": "r-version",
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


# -- current handlers --------------------------------------------------------


def _handle_current_no_args(func_name: str) -> Any:
    def handler(args: list[str]) -> None:
        from koopa import current
        fn = getattr(current, func_name)
        print(fn())
    return handler


def _handle_current_one_arg(func_name: str, arg_name: str) -> Any:
    def handler(args: list[str]) -> None:
        from koopa import current
        fn = getattr(current, func_name)
        for a in args:
            print(fn(a))
    return handler


def _handle_current_optional_arg(func_name: str) -> Any:
    def handler(args: list[str]) -> None:
        from koopa import current
        fn = getattr(current, func_name)
        if args:
            print(fn(args[0]))
        else:
            print(fn())
    return handler


# -- docker handlers ---------------------------------------------------------


def _handle_docker_build(args: list[str]) -> None:
    import argparse
    parser = argparse.ArgumentParser(prog="koopa app docker build")
    parser.add_argument("--local", required=True)
    parser.add_argument("--remote", required=True)
    parser.add_argument("--memory", default="")
    parser.add_argument("--no-push", action="store_true")
    parsed = parser.parse_args(args)
    from koopa.shell.docker import build
    build(
        local=parsed.local,
        remote=parsed.remote,
        memory=parsed.memory,
        no_push=parsed.no_push,
    )


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


def _handle_docker_prune_all_images(args: list[str]) -> None:
    from koopa.shell.docker import prune_all_images
    prune_all_images()


def _handle_docker_prune_old_images(args: list[str]) -> None:
    from koopa.shell.docker import prune_old_images
    prune_old_images()


def _handle_docker_remove(args: list[str]) -> None:
    if not args:
        print("Usage: koopa app docker remove <pattern>...", file=sys.stderr)
        sys.exit(1)
    from koopa.shell.docker import remove
    remove(*args)


def _handle_docker_run(args: list[str]) -> None:
    import argparse
    parser = argparse.ArgumentParser(prog="koopa app docker run")
    parser.add_argument("--arm", action="store_true")
    parser.add_argument("--x86", action="store_true")
    parser.add_argument("--bash", action="store_true")
    parser.add_argument("--bind", action="store_true")
    parser.add_argument("image")
    parsed = parser.parse_args(args)
    from koopa.shell.docker import run
    run(
        parsed.image,
        arm=parsed.arm,
        x86=parsed.x86,
        bash=parsed.bash,
        bind=parsed.bind,
    )


# -- r handlers --------------------------------------------------------------


def _handle_r_bioconda_check(args: list[str]) -> None:
    if not args:
        print(
            "Usage: koopa app r bioconda-check <package>...",
            file=sys.stderr,
        )
        sys.exit(1)
    from koopa.r import r_bioconda_check
    r_bioconda_check(*args)


def _handle_r_check(args: list[str]) -> None:
    if not args:
        print("Usage: koopa app r check <path>", file=sys.stderr)
        sys.exit(1)
    from koopa.r import r_check
    r_check(args[0])


def _handle_r_configure_environ(args: list[str]) -> None:
    from koopa.r import configure_r_environ
    r_home = args[0] if args else None
    configure_r_environ(r_home)


def _handle_r_configure_java(args: list[str]) -> None:
    from koopa.r import configure_r_java
    configure_r_java()


def _handle_r_configure_ldpaths(args: list[str]) -> None:
    if not args:
        print(
            "Usage: koopa app r configure-ldpaths <r-cmd>",
            file=sys.stderr,
        )
        sys.exit(1)
    from koopa.r import r_configure_ldpaths
    r_configure_ldpaths(args[0])


def _handle_r_configure_makevars(args: list[str]) -> None:
    from koopa.r import configure_r_makevars
    r_home = args[0] if args else None
    configure_r_makevars(r_home)


def _handle_r_copy_files_into_etc(args: list[str]) -> None:
    if not args:
        print(
            "Usage: koopa app r copy-files-into-etc <r-cmd>",
            file=sys.stderr,
        )
        sys.exit(1)
    from koopa.r import r_copy_files_into_etc
    r_copy_files_into_etc(args[0])


def _handle_r_gfortran_libs(args: list[str]) -> None:
    from koopa.r import r_gfortran_libs
    print(r_gfortran_libs())


def _handle_r_install_packages(args: list[str]) -> None:
    if not args:
        print(
            "Usage: koopa app r install-packages-in-site-library <pkg>...",
            file=sys.stderr,
        )
        sys.exit(1)
    from koopa.r import install_packages_in_site_library
    install_packages_in_site_library(args)


def _handle_r_migrate_non_base_packages(args: list[str]) -> None:
    if len(args) != 2:
        print(
            "Usage: koopa app r migrate-non-base-packages"
            " <from-lib> <to-lib>",
            file=sys.stderr,
        )
        sys.exit(1)
    from koopa.r import r_migrate_non_base_packages
    r_migrate_non_base_packages(args[0], args[1])


def _handle_r_package_version(args: list[str]) -> None:
    if not args:
        print(
            "Usage: koopa app r package-version <package>",
            file=sys.stderr,
        )
        sys.exit(1)
    from koopa.r import r_package_version
    print(r_package_version(args[0]))


def _handle_r_paste_to_vector(args: list[str]) -> None:
    if not args:
        print(
            "Usage: koopa app r paste-to-vector <item>...",
            file=sys.stderr,
        )
        sys.exit(1)
    from koopa.r import r_paste_to_vector
    print(r_paste_to_vector(args))


def _handle_r_remove_packages(args: list[str]) -> None:
    from koopa.r import remove_packages_in_system_library
    remove_packages_in_system_library()


def _handle_r_script(args: list[str]) -> None:
    if not args:
        print("Usage: koopa app r script <path>", file=sys.stderr)
        sys.exit(1)
    from koopa.r import r_script
    r_script(args[0])


def _handle_r_shiny_run_app(args: list[str]) -> None:
    import argparse
    parser = argparse.ArgumentParser(prog="koopa app r shiny-run-app")
    parser.add_argument("app_dir")
    parser.add_argument("--port", type=int, default=3838)
    parsed = parser.parse_args(args)
    from koopa.r import r_shiny_run_app
    r_shiny_run_app(parsed.app_dir, port=parsed.port)


def _handle_r_system_packages_non_base(args: list[str]) -> None:
    from koopa.r import r_system_packages_non_base
    for pkg in r_system_packages_non_base():
        print(pkg)


def _handle_r_version(args: list[str]) -> None:
    from koopa.r import r_version
    print(r_version())


# -- brew handlers -----------------------------------------------------------


def _handle_brew_reset_core_repo(args: list[str]) -> None:
    import shutil
    import subprocess
    from koopa.git import git_default_branch

    brew = shutil.which("brew")
    if brew is None:
        msg = "brew is not installed."
        raise RuntimeError(msg)
    git = shutil.which("git")
    if git is None:
        msg = "git is not installed."
        raise RuntimeError(msg)
    result = subprocess.run(
        [brew, "--repo", "homebrew/core"],
        capture_output=True, text=True, check=True,
    )
    prefix = result.stdout.strip()
    if not os.path.isdir(prefix):
        msg = f"Homebrew core repo not found: '{prefix}'."
        raise FileNotFoundError(msg)
    print(f"Resetting git repo at '{prefix}'.")
    branch = git_default_branch(prefix)
    origin = "origin"
    subprocess.run(
        [git, "checkout", "-q", branch], cwd=prefix, check=True,
    )
    subprocess.run(
        [git, "branch", "-q", branch, "-u", f"{origin}/{branch}"],
        cwd=prefix, check=True,
    )
    subprocess.run(
        [git, "reset", "-q", "--hard", f"{origin}/{branch}"],
        cwd=prefix, check=True,
    )


# -- git handlers ------------------------------------------------------------


def _handle_git_pull(args: list[str]) -> None:
    from koopa.git import git_pull
    path = args[0] if args else "."
    git_pull(path)


def _handle_git_push_submodules(args: list[str]) -> None:
    from koopa.git import git_push_submodules
    path = args[0] if args else "."
    git_push_submodules(path)


def _handle_git_rename_master_to_main(args: list[str]) -> None:
    from koopa.git import git_rename_master_to_main
    path = args[0] if args else "."
    git_rename_master_to_main(path)


def _handle_git_reset(args: list[str]) -> None:
    from koopa.git import git_reset
    path = args[0] if args else "."
    git_reset(path, hard=True)


def _handle_git_reset_fork_to_upstream(args: list[str]) -> None:
    from koopa.git import git_reset_fork_to_upstream
    path = args[0] if args else "."
    git_reset_fork_to_upstream(path)


def _handle_git_rm_submodule(args: list[str]) -> None:
    if not args:
        print(
            "Usage: koopa app git rm-submodule <submodule>",
            file=sys.stderr,
        )
        sys.exit(1)
    from koopa.git import git_rm_submodule
    git_rm_submodule(args[0])


def _handle_git_rm_untracked(args: list[str]) -> None:
    from koopa.git import git_rm_untracked
    path = args[0] if args else "."
    git_rm_untracked(path)


# -- handler registry --------------------------------------------------------


_PYTHON_HANDLERS: dict[str, Any] = {
    # current
    "current-aws-cli-version": _handle_current_no_args(
        "current_aws_cli_version",
    ),
    "current-bioconductor-version": _handle_current_no_args(
        "current_bioconductor_version",
    ),
    "current-conda-package-version": _handle_current_one_arg(
        "current_conda_package_version", "name",
    ),
    "current-ensembl-version": _handle_current_no_args(
        "current_ensembl_version",
    ),
    "current-flybase-version": _handle_current_no_args(
        "current_flybase_version",
    ),
    "current-gencode-version": _handle_current_optional_arg(
        "current_gencode_version",
    ),
    "current-git-version": _handle_current_no_args(
        "current_git_version",
    ),
    "current-github-release-version": _handle_current_one_arg(
        "current_github_release_version", "repo",
    ),
    "current-github-tag-version": _handle_current_one_arg(
        "current_github_tag_version", "repo",
    ),
    "current-gnu-ftp-version": _handle_current_one_arg(
        "current_gnu_ftp_version", "name",
    ),
    "current-google-cloud-sdk-version": _handle_current_no_args(
        "current_google_cloud_sdk_version",
    ),
    "current-latch-version": _handle_current_no_args(
        "current_latch_version",
    ),
    "current-pypi-package-version": _handle_current_one_arg(
        "current_pypi_package_version", "name",
    ),
    "current-python-version": _handle_current_no_args(
        "current_python_version",
    ),
    "current-refseq-version": _handle_current_no_args(
        "current_refseq_version",
    ),
    "current-wormbase-version": _handle_current_no_args(
        "current_wormbase_version",
    ),
    # brew
    "brew-reset-core-repo": _handle_brew_reset_core_repo,
    # docker
    "docker-build": _handle_docker_build,
    "docker-build-all-tags": _handle_docker_build_all_tags,
    "docker-prune-all-images": _handle_docker_prune_all_images,
    "docker-prune-old-images": _handle_docker_prune_old_images,
    "docker-remove": _handle_docker_remove,
    "docker-run": _handle_docker_run,
    # git
    "git-pull": _handle_git_pull,
    "git-push-submodules": _handle_git_push_submodules,
    "git-rename-master-to-main": _handle_git_rename_master_to_main,
    "git-reset": _handle_git_reset,
    "git-reset-fork-to-upstream": _handle_git_reset_fork_to_upstream,
    "git-rm-submodule": _handle_git_rm_submodule,
    "git-rm-untracked": _handle_git_rm_untracked,
    # r
    "r-bioconda-check": _handle_r_bioconda_check,
    "r-check": _handle_r_check,
    "r-configure-environ": _handle_r_configure_environ,
    "r-configure-java": _handle_r_configure_java,
    "r-configure-ldpaths": _handle_r_configure_ldpaths,
    "r-configure-makevars": _handle_r_configure_makevars,
    "r-copy-files-into-etc": _handle_r_copy_files_into_etc,
    "r-gfortran-libs": _handle_r_gfortran_libs,
    "r-install-packages-in-site-library": _handle_r_install_packages,
    "r-migrate-non-base-packages": _handle_r_migrate_non_base_packages,
    "r-package-version": _handle_r_package_version,
    "r-paste-to-vector": _handle_r_paste_to_vector,
    "r-remove-packages-in-system-library": _handle_r_remove_packages,
    "r-script": _handle_r_script,
    "r-shiny-run-app": _handle_r_shiny_run_app,
    "r-system-packages-non-base": _handle_r_system_packages_non_base,
    "r-version": _handle_r_version,
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
