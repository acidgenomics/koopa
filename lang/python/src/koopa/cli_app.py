"""Dispatch table for ``koopa app`` subcommands."""

from __future__ import annotations

import os
import shutil
import subprocess
import sys
from collections.abc import Callable
from typing import Any

_APP_TREE: dict[str, Any] = {
    "aws": {
        "batch": {
            "list-jobs": "aws-batch-list-jobs",
        },
        "ec2": {
            "list-running-instances": "aws-ec2-list-running-instances",
        },
        "ecr": {
            "login-private": "aws-ecr-login-private",
            "login-public": "aws-ecr-login-public",
        },
        "s3": {
            "find": "aws-s3-find",
            "list-large-files": "aws-s3-list-large-files",
            "ls": "aws-s3-ls",
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
    "rnaeditingindexer": "rnaeditingindexer",
    "rsem": {
        "index": "rsem-index",
        "quant": {
            "bam": "rsem-quant-bam",
        },
    },
    "salmon": {
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


def _handle_current_no_args(func_name: str) -> Callable[[list[str]], None]:
    def handler(args: list[str]) -> None:
        from koopa import current

        fn = getattr(current, func_name)
        print(fn())

    return handler


def _handle_current_one_arg(func_name: str, arg_name: str) -> Callable[[list[str]], None]:
    def handler(args: list[str]) -> None:
        from koopa import current

        fn = getattr(current, func_name)
        for a in args:
            print(fn(a))

    return handler


def _handle_current_optional_arg(func_name: str) -> Callable[[list[str]], None]:
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
            "Usage: koopa app r migrate-non-base-packages <from-lib> <to-lib>",
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
        capture_output=True,
        text=True,
        check=True,
    )
    prefix = result.stdout.strip()
    if not os.path.isdir(prefix):
        msg = f"Homebrew core repo not found: '{prefix}'."
        raise FileNotFoundError(msg)
    print(f"Resetting git repo at '{prefix}'.")
    branch = git_default_branch(prefix)
    origin = "origin"
    subprocess.run(
        [git, "checkout", "-q", branch],
        cwd=prefix,
        check=True,
    )
    subprocess.run(
        [git, "branch", "-q", branch, "-u", f"{origin}/{branch}"],
        cwd=prefix,
        check=True,
    )
    subprocess.run(
        [git, "reset", "-q", "--hard", f"{origin}/{branch}"],
        cwd=prefix,
        check=True,
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


# -- bioinformatics handlers -------------------------------------------------


def _handle_bowtie2_align_paired_end(args: list[str]) -> None:
    import argparse

    parser = argparse.ArgumentParser(prog="koopa app bowtie2 align paired-end")
    parser.add_argument("--index-dir", required=True)
    parser.add_argument("--fastq-dir", required=True)
    parser.add_argument("--output-dir", required=True)
    parsed = parser.parse_args(args)
    from koopa.ngs import bowtie2_align

    bowtie2_align(
        parsed.index_dir,
        os.path.join(parsed.output_dir, "aligned.sam"),
        r1=os.path.join(parsed.fastq_dir, "R1.fastq.gz"),
        r2=os.path.join(parsed.fastq_dir, "R2.fastq.gz"),
    )


def _handle_bowtie2_index(args: list[str]) -> None:
    import argparse

    parser = argparse.ArgumentParser(prog="koopa app bowtie2 index")
    parser.add_argument("--genome-fasta-file", required=True)
    parser.add_argument("--output-dir", required=True)
    parsed = parser.parse_args(args)
    from koopa.ngs import bowtie2_build

    index_prefix = os.path.join(parsed.output_dir, "bowtie2")
    os.makedirs(parsed.output_dir, exist_ok=True)
    bowtie2_build(
        parsed.genome_fasta_file,
        index_prefix,
        threads=os.cpu_count() or 1,
    )


def _handle_hisat2_align(args: list[str], *, mode: str = "paired-end") -> None:
    import argparse

    prog = f"koopa app hisat2 align {mode}"
    parser = argparse.ArgumentParser(prog=prog)
    parser.add_argument("--index-dir", required=True)
    parser.add_argument("--fastq-dir", required=True)
    parser.add_argument("--output-dir", required=True)
    parser.add_argument("--gtf-file", default="")
    parsed = parser.parse_args(args)
    hisat2 = shutil.which("hisat2")
    if hisat2 is None:
        msg = "hisat2 is not installed."
        raise RuntimeError(msg)
    os.makedirs(parsed.output_dir, exist_ok=True)
    hisat2_args = [
        hisat2,
        "-x",
        os.path.join(parsed.index_dir, "hisat2"),
        "-S",
        os.path.join(parsed.output_dir, "aligned.sam"),
        "--threads",
        str(os.cpu_count() or 1),
    ]
    if mode == "paired-end":
        hisat2_args.extend(
            [
                "-1",
                os.path.join(parsed.fastq_dir, "R1.fastq.gz"),
                "-2",
                os.path.join(parsed.fastq_dir, "R2.fastq.gz"),
            ]
        )
    else:
        hisat2_args.extend(
            [
                "-U",
                os.path.join(parsed.fastq_dir, "R1.fastq.gz"),
            ]
        )
    subprocess.run(hisat2_args, check=True)


def _handle_hisat2_index(args: list[str]) -> None:
    import argparse

    parser = argparse.ArgumentParser(prog="koopa app hisat2 index")
    parser.add_argument("--genome-fasta-file", required=True)
    parser.add_argument("--output-dir", required=True)
    parser.add_argument("--gtf-file", default="")
    parsed = parser.parse_args(args)
    from koopa.ngs import hisat2_build

    os.makedirs(parsed.output_dir, exist_ok=True)
    hisat2_build(
        parsed.genome_fasta_file,
        os.path.join(parsed.output_dir, "hisat2"),
        threads=os.cpu_count() or 1,
    )


def _handle_kallisto_index(args: list[str]) -> None:
    import argparse

    parser = argparse.ArgumentParser(prog="koopa app kallisto index")
    parser.add_argument("--transcriptome-fasta-file", required=True)
    parser.add_argument("--output-dir", required=True)
    parsed = parser.parse_args(args)
    from koopa.ngs import kallisto_index

    os.makedirs(parsed.output_dir, exist_ok=True)
    kallisto_index(
        parsed.transcriptome_fasta_file,
        os.path.join(parsed.output_dir, "kallisto.idx"),
    )


def _handle_kallisto_quant(args: list[str], *, mode: str = "paired-end") -> None:
    import argparse

    prog = f"koopa app kallisto quant {mode}"
    parser = argparse.ArgumentParser(prog=prog)
    parser.add_argument("--index-dir", required=True)
    parser.add_argument("--fastq-dir", required=True)
    parser.add_argument("--output-dir", required=True)
    parsed = parser.parse_args(args)
    from koopa.ngs import kallisto_quant

    index_file = os.path.join(parsed.index_dir, "kallisto.idx")
    os.makedirs(parsed.output_dir, exist_ok=True)
    r1 = os.path.join(parsed.fastq_dir, "R1.fastq.gz")
    if mode == "paired-end":
        r2 = os.path.join(parsed.fastq_dir, "R2.fastq.gz")
        kallisto_quant(index_file, parsed.output_dir, r1=r1, r2=r2)
    else:
        kallisto_quant(index_file, parsed.output_dir, r1=r1)


def _handle_miso_index(args: list[str]) -> None:
    import argparse

    parser = argparse.ArgumentParser(prog="koopa app miso index")
    parser.add_argument("--gff-file", required=True)
    parser.add_argument("--output-dir", required=True)
    parsed = parser.parse_args(args)
    from koopa.ngs import miso_index

    miso_index(parsed.gff_file, parsed.output_dir)


def _handle_rnaeditingindexer(args: list[str]) -> None:
    import argparse

    parser = argparse.ArgumentParser(prog="koopa app rnaeditingindexer")
    parser.add_argument("--bam-dir", default="bam")
    parser.add_argument("--output-dir", default="rnaedit")
    parser.add_argument("--genome", default="hg38")
    parser.add_argument("--example", action="store_true")
    parsed = parser.parse_args(args)
    from koopa.ngs import rnaeditingindexer

    rnaeditingindexer(
        bam_dir=parsed.bam_dir,
        output_dir=parsed.output_dir,
        genome=parsed.genome,
        example=parsed.example,
    )


def _handle_rsem_index(args: list[str]) -> None:
    import argparse

    parser = argparse.ArgumentParser(prog="koopa app rsem index")
    parser.add_argument("--genome-fasta-file", required=True)
    parser.add_argument("--output-dir", required=True)
    parser.add_argument("--gtf-file", default="")
    parser.add_argument("--num-threads", type=int, default=0)
    parsed = parser.parse_args(args)
    from koopa.ngs import rsem_prepare_reference

    threads = parsed.num_threads or (os.cpu_count() or 1)
    os.makedirs(parsed.output_dir, exist_ok=True)
    rsem_prepare_reference(
        parsed.genome_fasta_file,
        os.path.join(parsed.output_dir, "rsem"),
        gtf=parsed.gtf_file or None,
        threads=threads,
    )


def _handle_rsem_quant_bam(args: list[str]) -> None:
    import argparse

    parser = argparse.ArgumentParser(prog="koopa app rsem quant bam")
    parser.add_argument("--bam-file", required=True)
    parser.add_argument("--index-dir", required=True)
    parser.add_argument("--output-dir", required=True)
    parsed = parser.parse_args(args)
    from koopa.ngs import rsem_calculate_expression

    os.makedirs(parsed.output_dir, exist_ok=True)
    rsem_calculate_expression(
        parsed.bam_file,
        os.path.join(parsed.index_dir, "rsem"),
        os.path.join(parsed.output_dir, "rsem"),
    )


def _handle_salmon_index(args: list[str]) -> None:
    import argparse

    parser = argparse.ArgumentParser(prog="koopa app salmon index")
    parser.add_argument("--transcriptome-fasta-file", required=True)
    parser.add_argument("--output-dir", required=True)
    parsed = parser.parse_args(args)
    from koopa.ngs import salmon_index

    salmon_index(
        parsed.transcriptome_fasta_file,
        parsed.output_dir,
        threads=os.cpu_count() or 1,
    )


def _handle_salmon_quant(args: list[str], *, mode: str = "paired-end") -> None:
    import argparse

    prog = f"koopa app salmon quant {mode}"
    parser = argparse.ArgumentParser(prog=prog)
    parser.add_argument("--index-dir", required=True)
    parser.add_argument("--fastq-dir", required=True)
    parser.add_argument("--output-dir", required=True)
    parsed = parser.parse_args(args)
    from koopa.ngs import salmon_quant

    r1 = os.path.join(parsed.fastq_dir, "R1.fastq.gz")
    if mode == "paired-end":
        r2 = os.path.join(parsed.fastq_dir, "R2.fastq.gz")
        salmon_quant(parsed.index_dir, parsed.output_dir, r1=r1, r2=r2)
    elif mode == "single-end":
        salmon_quant(parsed.index_dir, parsed.output_dir, unmated=r1)
    elif mode == "bam":
        salmon_quant(parsed.index_dir, parsed.output_dir, r1=r1)


def _handle_star_align(args: list[str], *, mode: str = "paired-end") -> None:
    import argparse

    prog = f"koopa app star align {mode}"
    parser = argparse.ArgumentParser(prog=prog)
    parser.add_argument("--index-dir", required=True)
    parser.add_argument("--fastq-dir", required=True)
    parser.add_argument("--output-dir", required=True)
    parser.add_argument("--gtf-file", default="")
    parsed = parser.parse_args(args)
    from koopa.ngs import star_align

    os.makedirs(parsed.output_dir, exist_ok=True)
    r1 = os.path.join(parsed.fastq_dir, "R1.fastq.gz")
    r2 = os.path.join(parsed.fastq_dir, "R2.fastq.gz") if mode == "paired-end" else None
    star_align(
        parsed.index_dir,
        os.path.join(parsed.output_dir, "star_"),
        r1=r1,
        r2=r2,
        threads=os.cpu_count() or 1,
    )


def _handle_star_index(args: list[str]) -> None:
    import argparse

    parser = argparse.ArgumentParser(prog="koopa app star index")
    parser.add_argument("--genome-fasta-file", required=True)
    parser.add_argument("--output-dir", required=True)
    parser.add_argument("--gtf-file", default="")
    parsed = parser.parse_args(args)
    from koopa.ngs import star_index

    star_index(
        parsed.genome_fasta_file,
        parsed.output_dir,
        gtf=parsed.gtf_file or None,
        threads=os.cpu_count() or 1,
    )


# -- sra handlers ------------------------------------------------------------


def _handle_sra_prefetch(args: list[str]) -> None:
    import argparse

    parser = argparse.ArgumentParser(prog="koopa app sra prefetch")
    parser.add_argument("--accession-file", required=True)
    parser.add_argument("--output-dir", required=True)
    parsed = parser.parse_args(args)
    from koopa.sra import sra_prefetch

    sra_prefetch(parsed.accession_file, parsed.output_dir)


def _handle_sra_fastq_dump(args: list[str]) -> None:
    import argparse

    parser = argparse.ArgumentParser(prog="koopa app sra fastq-dump")
    parser.add_argument("--prefetch-directory", required=True)
    parser.add_argument("--fastq-directory", required=True)
    parser.add_argument("--no-compress", action="store_true")
    parsed = parser.parse_args(args)
    from koopa.sra import sra_fastq_dump

    sra_fastq_dump(
        parsed.prefetch_directory,
        parsed.fastq_directory,
        compress=not parsed.no_compress,
    )


def _handle_sra_download_accession_list(args: list[str]) -> None:
    import argparse

    parser = argparse.ArgumentParser(
        prog="koopa app sra download-accession-list",
    )
    parser.add_argument("--srp-id", required=True)
    parser.add_argument("--file", default="")
    parsed = parser.parse_args(args)
    from koopa.sra import sra_download_accession_list

    sra_download_accession_list(parsed.srp_id, parsed.file)


def _handle_sra_download_run_info_table(args: list[str]) -> None:
    import argparse

    parser = argparse.ArgumentParser(
        prog="koopa app sra download-run-info-table",
    )
    parser.add_argument("--srp-id", required=True)
    parser.add_argument("--file", default="")
    parsed = parser.parse_args(args)
    from koopa.sra import sra_download_run_info_table

    sra_download_run_info_table(parsed.srp_id, parsed.file)


# -- brew handlers (additional) ----------------------------------------------


def _handle_brew_cleanup(args: list[str]) -> None:
    from koopa.brew import _brew

    _brew("cleanup", capture=False)


def _handle_brew_dump_brewfile(args: list[str]) -> None:
    from koopa.brew import brew_dump_brewfile

    path = args[0] if args else "Brewfile"
    brew_dump_brewfile(path)


def _handle_brew_outdated(args: list[str]) -> None:
    from koopa.brew import brew_outdated

    for pkg in brew_outdated():
        print(pkg)


def _handle_brew_reset_permissions(args: list[str]) -> None:
    from koopa.brew import brew_reset_permissions

    brew_reset_permissions()


def _handle_brew_uninstall_all_brews(args: list[str]) -> None:
    from koopa.brew import brew_uninstall_all_brews

    brew_uninstall_all_brews()


def _handle_brew_upgrade_brews(args: list[str]) -> None:
    from koopa.brew import brew_upgrade_brews

    brew_upgrade_brews()


def _handle_brew_version(args: list[str]) -> None:
    from koopa.brew import brew_version

    print(brew_version())


# -- conda handlers ----------------------------------------------------------


def _handle_conda_create_env(args: list[str]) -> None:
    import argparse

    parser = argparse.ArgumentParser(prog="koopa app conda create-env")
    parser.add_argument("--file", default="")
    parser.add_argument("--prefix", default="")
    parser.add_argument("--force", action="store_true")
    parser.add_argument("--latest", action="store_true")
    parser.add_argument("packages", nargs="*")
    parsed = parser.parse_args(args)
    from koopa.conda import conda_create_env

    conda_create_env(
        *parsed.packages,
        prefix=parsed.prefix,
        yaml_file=parsed.file,
        force=parsed.force,
        latest=parsed.latest,
    )


def _handle_conda_remove_env(args: list[str]) -> None:
    if not args:
        print("Usage: koopa app conda remove-env <name>...", file=sys.stderr)
        sys.exit(1)
    from koopa.conda import conda_remove_env

    conda_remove_env(*args)


# -- gpg handlers ------------------------------------------------------------


def _handle_gpg_prompt(args: list[str]) -> None:
    from koopa.gpg import gpg_prompt

    gpg_prompt()


def _handle_gpg_reload(args: list[str]) -> None:
    from koopa.gpg import gpg_reload

    gpg_reload()


def _handle_gpg_restart(args: list[str]) -> None:
    from koopa.gpg import gpg_restart

    gpg_restart()


# -- ssh handlers ------------------------------------------------------------


def _handle_ssh_generate_key(args: list[str]) -> None:
    import argparse

    parser = argparse.ArgumentParser(prog="koopa app ssh generate-key")
    parser.add_argument("--prefix", default="")
    parser.add_argument("key_names", nargs="*", default=["id_rsa"])
    parsed = parser.parse_args(args)
    from koopa.ssh import ssh_generate_key

    ssh_generate_key(*parsed.key_names, prefix=parsed.prefix)


# -- aws handlers ------------------------------------------------------------


def _handle_aws_batch_list_jobs(args: list[str]) -> None:
    import argparse

    parser = argparse.ArgumentParser(prog="koopa app aws batch list-jobs")
    parser.add_argument("--queue", required=True)
    parser.add_argument("--status", default="RUNNING")
    parser.add_argument("--profile", default=None)
    parsed = parser.parse_args(args)
    import json

    from koopa.aws import aws_batch_list_jobs

    jobs = aws_batch_list_jobs(
        parsed.queue,
        status=parsed.status,
        profile=parsed.profile,
    )
    print(json.dumps(jobs, indent=2))


def _handle_aws_ec2_list_running_instances(args: list[str]) -> None:
    import argparse

    parser = argparse.ArgumentParser(
        prog="koopa app aws ec2 list-running-instances",
    )
    parser.add_argument("--profile", default=None)
    parsed = parser.parse_args(args)
    from koopa.aws import aws_ec2_list_running_instances

    instances = aws_ec2_list_running_instances(profile=parsed.profile)
    for inst in instances:
        parts = [inst["id"], inst["type"], inst["state"]]
        if inst["name"]:
            parts.append(inst["name"])
        if inst["ip"]:
            parts.append(inst["ip"])
        print("\t".join(parts))


def _handle_aws_ecr_login_private(args: list[str]) -> None:
    import argparse

    parser = argparse.ArgumentParser(
        prog="koopa app aws ecr login-private",
    )
    parser.add_argument("--region", default="us-east-1")
    parser.add_argument("--account-id", default=None)
    parser.add_argument("--profile", default=None)
    parsed = parser.parse_args(args)
    from koopa.aws import aws_ecr_login_private

    aws_ecr_login_private(
        parsed.region,
        account_id=parsed.account_id,
        profile=parsed.profile,
    )


def _handle_aws_ecr_login_public(args: list[str]) -> None:
    import argparse

    parser = argparse.ArgumentParser(
        prog="koopa app aws ecr login-public",
    )
    parser.add_argument("--region", default="us-east-1")
    parsed = parser.parse_args(args)
    from koopa.aws import aws_ecr_login_public

    aws_ecr_login_public(parsed.region)


def _handle_aws_s3_find(args: list[str]) -> None:
    import argparse

    parser = argparse.ArgumentParser(prog="koopa app aws s3 find")
    parser.add_argument("--bucket", required=True)
    parser.add_argument("--prefix", default="")
    parser.add_argument("--pattern", default="")
    parser.add_argument("--profile", default=None)
    parsed = parser.parse_args(args)
    from koopa.aws import aws_s3_find

    keys = aws_s3_find(
        parsed.bucket,
        prefix=parsed.prefix,
        pattern=parsed.pattern,
        profile=parsed.profile,
    )
    for key in keys:
        print(key)


def _handle_aws_s3_list_large_files(args: list[str]) -> None:
    import argparse

    parser = argparse.ArgumentParser(
        prog="koopa app aws s3 list-large-files",
    )
    parser.add_argument("--bucket", required=True)
    parser.add_argument("--min-size-mb", type=float, default=100)
    parser.add_argument("--prefix", default="")
    parser.add_argument("--profile", default=None)
    parsed = parser.parse_args(args)
    from koopa.aws import aws_s3_list_large_files

    files = aws_s3_list_large_files(
        parsed.bucket,
        min_size_mb=parsed.min_size_mb,
        prefix=parsed.prefix,
        profile=parsed.profile,
    )
    for key, size_mb in files:
        print(f"{size_mb:.1f} MB\t{key}")


def _handle_aws_s3_ls(args: list[str]) -> None:
    import argparse

    parser = argparse.ArgumentParser(prog="koopa app aws s3 ls")
    parser.add_argument("path")
    parser.add_argument("--recursive", action="store_true")
    parser.add_argument("--profile", default=None)
    parsed = parser.parse_args(args)
    from koopa.aws import aws_s3_ls

    output = aws_s3_ls(
        parsed.path,
        recursive=parsed.recursive,
        profile=parsed.profile,
    )
    print(output, end="")


def _handle_aws_s3_sync(args: list[str]) -> None:
    import argparse

    parser = argparse.ArgumentParser(prog="koopa app aws s3 sync")
    parser.add_argument("source")
    parser.add_argument("target")
    parser.add_argument("--delete", action="store_true")
    parser.add_argument("--dryrun", action="store_true")
    parser.add_argument("--exclude", action="append", default=None)
    parser.add_argument("--include", action="append", default=None)
    parser.add_argument("--profile", default=None)
    parsed = parser.parse_args(args)
    from koopa.aws import aws_s3_sync

    aws_s3_sync(
        parsed.source,
        parsed.target,
        delete=parsed.delete,
        dryrun=parsed.dryrun,
        exclude=parsed.exclude,
        include=parsed.include,
        profile=parsed.profile,
    )


# -- bioconda handlers -------------------------------------------------------


def _handle_bioconda_autobump_recipe(args: list[str]) -> None:
    if not args:
        print(
            "Usage: koopa app bioconda autobump-recipe <recipe>",
            file=sys.stderr,
        )
        sys.exit(1)
    git = shutil.which("git")
    vim = shutil.which("vim")
    if git is None:
        msg = "git is not installed."
        raise RuntimeError(msg)
    if vim is None:
        msg = "vim is not installed."
        raise RuntimeError(msg)
    recipe = args[0]
    repo = os.path.join(os.path.expanduser("~"), "git", "github", "bioconda", "bioconda-recipes")
    if not os.path.isdir(repo):
        msg = f"Bioconda recipes repo not found: '{repo}'."
        raise FileNotFoundError(msg)
    branch = recipe.replace("-", "_")
    subprocess.run([git, "checkout", "master"], cwd=repo, check=True)
    subprocess.run([git, "fetch", "--all"], cwd=repo, check=True)
    subprocess.run([git, "pull"], cwd=repo, check=True)
    subprocess.run(
        [git, "checkout", "-B", branch, f"origin/bump/{branch}"],
        cwd=repo,
        check=True,
    )
    subprocess.run([git, "pull", "origin", "master"], cwd=repo, check=True)
    recipe_dir = os.path.join(repo, "recipes", recipe)
    os.makedirs(recipe_dir, exist_ok=True)
    meta_yaml = os.path.join(recipe_dir, "meta.yaml")
    subprocess.run([vim, meta_yaml], cwd=repo, check=True)


# -- ftp handlers ------------------------------------------------------------


def _handle_ftp_mirror(args: list[str]) -> None:
    import argparse

    parser = argparse.ArgumentParser(prog="koopa app ftp mirror")
    parser.add_argument("--host", required=True)
    parser.add_argument("--user", required=True)
    parser.add_argument("--dir", default="")
    parsed = parser.parse_args(args)
    wget = shutil.which("wget")
    if wget is None:
        msg = "wget is not installed."
        raise RuntimeError(msg)
    target = f"{parsed.host}/{parsed.dir}" if parsed.dir else parsed.host
    subprocess.run(
        [wget, "--ask-password", "--mirror", f"ftp://{parsed.user}@{target}/*"],
        check=True,
    )


# -- jekyll handlers ---------------------------------------------------------


def _handle_jekyll_serve(args: list[str]) -> None:
    bundle = shutil.which("bundle")
    if bundle is None:
        msg = "bundle is not installed."
        raise RuntimeError(msg)
    from koopa.xdg import xdg_data_home

    bundle_prefix = os.path.join(xdg_data_home(), "gem")
    prefix = args[0] if args else os.getcwd()
    prefix = os.path.realpath(prefix)
    gemfile = os.path.join(prefix, "Gemfile")
    if not os.path.isfile(gemfile):
        msg = f"Gemfile not found in '{prefix}'."
        raise FileNotFoundError(msg)
    from koopa.alert import alert

    alert(f"Serving Jekyll website in '{prefix}'.")
    subprocess.run(
        [bundle, "config", "set", "--local", "path", bundle_prefix],
        cwd=prefix,
        check=True,
    )
    lock = os.path.join(prefix, "Gemfile.lock")
    if os.path.isfile(lock):
        os.remove(lock)
    subprocess.run([bundle, "install"], cwd=prefix, check=True)
    subprocess.run([bundle, "exec", "jekyll", "serve"], cwd=prefix, check=True)
    lock = os.path.join(prefix, "Gemfile.lock")
    if os.path.isfile(lock):
        os.remove(lock)


# -- md5sum handlers ---------------------------------------------------------


def _handle_md5sum_check_to_new_md5_file(args: list[str]) -> None:
    if not args:
        print(
            "Usage: koopa app md5sum check-to-new-md5-file <file>...",
            file=sys.stderr,
        )
        sys.exit(1)
    from datetime import UTC, datetime

    md5sum = shutil.which("md5sum")
    if md5sum is None:
        msg = "md5sum is not installed."
        raise RuntimeError(msg)
    dt = datetime.now(tz=UTC).strftime("%Y%m%d-%H%M%S")
    log_file = f"md5sum-{dt}.md5"
    if os.path.isfile(log_file):
        msg = f"Log file already exists: '{log_file}'."
        raise FileExistsError(msg)
    for f in args:
        if not os.path.isfile(f):
            msg = f"File not found: '{f}'."
            raise FileNotFoundError(msg)
    with open(log_file, "w") as log_fh:
        proc = subprocess.run(
            [md5sum, *args],
            capture_output=True,
            text=True,
            check=True,
        )
        output = proc.stdout
        sys.stdout.write(output)
        log_fh.write(output)


# -- wget handlers -----------------------------------------------------------


def _handle_wget_recursive(args: list[str]) -> None:
    import argparse

    parser = argparse.ArgumentParser(prog="koopa app wget recursive")
    parser.add_argument("--url", required=True)
    parser.add_argument("--user", required=True)
    parser.add_argument("--password", required=True)
    parsed = parser.parse_args(args)
    wget = shutil.which("wget")
    if wget is None:
        msg = "wget is not installed."
        raise RuntimeError(msg)
    from datetime import UTC, datetime

    dt = datetime.now(tz=UTC).strftime("%Y%m%d-%H%M%S")
    log_file = f"wget-{dt}.log"
    subprocess.run(
        [
            wget,
            f"--output-file={log_file}",
            f"--password={parsed.password}",
            f"--user={parsed.user}",
            "--continue",
            "--debug",
            "--no-parent",
            "--recursive",
            f"{parsed.url}/*",
        ],
        check=True,
    )


# -- handler registry --------------------------------------------------------


_PYTHON_HANDLERS: dict[str, Any] = {
    # app utilities
    "bioconda-autobump-recipe": _handle_bioconda_autobump_recipe,
    "ftp-mirror": _handle_ftp_mirror,
    "jekyll-serve": _handle_jekyll_serve,
    "md5sum-check-to-new-md5-file": _handle_md5sum_check_to_new_md5_file,
    "wget-recursive": _handle_wget_recursive,
    # aws
    "aws-batch-list-jobs": _handle_aws_batch_list_jobs,
    "aws-ec2-list-running-instances": _handle_aws_ec2_list_running_instances,
    "aws-ecr-login-private": _handle_aws_ecr_login_private,
    "aws-ecr-login-public": _handle_aws_ecr_login_public,
    "aws-s3-find": _handle_aws_s3_find,
    "aws-s3-list-large-files": _handle_aws_s3_list_large_files,
    "aws-s3-ls": _handle_aws_s3_ls,
    "aws-s3-sync": _handle_aws_s3_sync,
    # bioinformatics
    "bowtie2-align-paired-end": _handle_bowtie2_align_paired_end,
    "bowtie2-index": _handle_bowtie2_index,
    "hisat2-align-paired-end": lambda a: _handle_hisat2_align(
        a,
        mode="paired-end",
    ),
    "hisat2-align-single-end": lambda a: _handle_hisat2_align(
        a,
        mode="single-end",
    ),
    "hisat2-index": _handle_hisat2_index,
    "kallisto-index": _handle_kallisto_index,
    "kallisto-quant-paired-end": lambda a: _handle_kallisto_quant(
        a,
        mode="paired-end",
    ),
    "kallisto-quant-single-end": lambda a: _handle_kallisto_quant(
        a,
        mode="single-end",
    ),
    "miso-index": _handle_miso_index,
    "rnaeditingindexer": _handle_rnaeditingindexer,
    "rsem-index": _handle_rsem_index,
    "rsem-quant-bam": _handle_rsem_quant_bam,
    "salmon-index": _handle_salmon_index,
    "salmon-quant-bam": lambda a: _handle_salmon_quant(a, mode="bam"),
    "salmon-quant-paired-end": lambda a: _handle_salmon_quant(
        a,
        mode="paired-end",
    ),
    "salmon-quant-single-end": lambda a: _handle_salmon_quant(
        a,
        mode="single-end",
    ),
    "star-align-paired-end": lambda a: _handle_star_align(
        a,
        mode="paired-end",
    ),
    "star-align-single-end": lambda a: _handle_star_align(
        a,
        mode="single-end",
    ),
    "star-index": _handle_star_index,
    # brew
    "brew-cleanup": _handle_brew_cleanup,
    "brew-dump-brewfile": _handle_brew_dump_brewfile,
    "brew-outdated": _handle_brew_outdated,
    "brew-reset-core-repo": _handle_brew_reset_core_repo,
    "brew-reset-permissions": _handle_brew_reset_permissions,
    "brew-uninstall-all-brews": _handle_brew_uninstall_all_brews,
    "brew-upgrade-brews": _handle_brew_upgrade_brews,
    "brew-version": _handle_brew_version,
    # conda
    "conda-create-env": _handle_conda_create_env,
    "conda-remove-env": _handle_conda_remove_env,
    # current
    "current-aws-cli-version": _handle_current_no_args(
        "current_aws_cli_version",
    ),
    "current-bioconductor-version": _handle_current_no_args(
        "current_bioconductor_version",
    ),
    "current-conda-package-version": _handle_current_one_arg(
        "current_conda_package_version",
        "name",
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
        "current_github_release_version",
        "repo",
    ),
    "current-github-tag-version": _handle_current_one_arg(
        "current_github_tag_version",
        "repo",
    ),
    "current-gnu-ftp-version": _handle_current_one_arg(
        "current_gnu_ftp_version",
        "name",
    ),
    "current-google-cloud-sdk-version": _handle_current_no_args(
        "current_google_cloud_sdk_version",
    ),
    "current-latch-version": _handle_current_no_args(
        "current_latch_version",
    ),
    "current-pypi-package-version": _handle_current_one_arg(
        "current_pypi_package_version",
        "name",
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
    # gpg
    "gpg-prompt": _handle_gpg_prompt,
    "gpg-reload": _handle_gpg_reload,
    "gpg-restart": _handle_gpg_restart,
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
    # sra
    "sra-download-accession-list": _handle_sra_download_accession_list,
    "sra-download-run-info-table": _handle_sra_download_run_info_table,
    "sra-fastq-dump": _handle_sra_fastq_dump,
    "sra-prefetch": _handle_sra_prefetch,
    # ssh
    "ssh-generate-key": _handle_ssh_generate_key,
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
    if handler is None:
        print(f"Error: unknown app command '{key}'.", file=sys.stderr)
        sys.exit(1)
    handler(args)
