"""Dispatch module for koopa bin/ scripts.

Each bin/ script delegates to this module via:
    python3 -m koopa.cli_bin <script-name> [args...]
"""

from __future__ import annotations

import csv
import os
import re
import shutil
import socket
import subprocess
import sys
import urllib.request
from collections import Counter
from collections.abc import Callable
from datetime import UTC, datetime
from pathlib import Path
from typing import TYPE_CHECKING

if TYPE_CHECKING:
    import argparse


def _which(name: str) -> str:
    """Locate a command."""
    path = shutil.which(name)
    if path is None:
        msg = f"Command not found: {name}"
        raise FileNotFoundError(msg)
    return path


# -- Text processing -----------------------------------------------------------


def _handle_autopad_zeros(args: list[str]) -> None:
    import argparse

    from koopa.text import autopad_zeros

    parser = argparse.ArgumentParser(
        prog="autopad-zeros",
        description="Autopad zeros in numbered file names.",
    )
    parser.add_argument("directory", help="directory to process")
    parsed = parser.parse_args(args)
    renames = autopad_zeros(parsed.directory)
    for old, new in renames:
        print(f"{old} -> {new}", file=sys.stderr)


def _handle_detab(args: list[str]) -> None:
    import argparse

    from koopa.text import detab

    parser = argparse.ArgumentParser(
        prog="detab",
        description="Convert tabs to spaces.",
    )
    parser.add_argument("files", nargs="+", help="files to process")
    parsed = parser.parse_args(args)
    for path in parsed.files:
        detab(path)


def _handle_entab(args: list[str]) -> None:
    import argparse

    from koopa.text import entab

    parser = argparse.ArgumentParser(
        prog="entab",
        description="Convert spaces to tabs.",
    )
    parser.add_argument("files", nargs="+", help="files to process")
    parsed = parser.parse_args(args)
    for path in parsed.files:
        entab(path)


def _handle_eol_lf(args: list[str]) -> None:
    import argparse

    from koopa.text import eol_lf

    parser = argparse.ArgumentParser(
        prog="eol-lf",
        description="Convert line endings to LF.",
    )
    parser.add_argument("files", nargs="+", help="files to process")
    parsed = parser.parse_args(args)
    for path in parsed.files:
        eol_lf(path)


def _handle_find_and_replace(args: list[str]) -> None:
    import argparse

    from koopa.text import find_and_replace_in_file

    parser = argparse.ArgumentParser(
        prog="find-and-replace",
        description="Find and replace text in files.",
    )
    parser.add_argument("--fixed", action="store_true", help="treat pattern as fixed string")
    parser.add_argument("--regex", action="store_true", help="treat pattern as regex (default)")
    parser.add_argument("pattern", help="search pattern")
    parser.add_argument("replacement", help="replacement string")
    parser.add_argument("files", nargs="+", help="files to process")
    parsed = parser.parse_args(args)
    for path in parsed.files:
        find_and_replace_in_file(path, parsed.pattern, parsed.replacement, fixed=parsed.fixed)


def _handle_find_files_without_line_ending(args: list[str]) -> None:
    import argparse

    from koopa.text import find_files_without_line_ending

    parser = argparse.ArgumentParser(
        prog="find-files-without-line-ending",
        description="Find files missing a final newline.",
    )
    parser.add_argument("directory", help="directory to scan")
    parsed = parser.parse_args(args)
    for path in find_files_without_line_ending(parsed.directory):
        print(path)


def _handle_sort_lines(args: list[str]) -> None:
    import argparse

    from koopa.text import sort_lines

    parser = argparse.ArgumentParser(
        prog="sort-lines",
        description="Sort lines in files.",
    )
    parser.add_argument("files", nargs="+", help="files to process")
    parsed = parser.parse_args(args)
    for path in parsed.files:
        sort_lines(path)


def _handle_line_count(args: list[str]) -> None:
    import argparse

    from koopa.file_ops import line_count

    parser = argparse.ArgumentParser(
        prog="line-count",
        description="Count lines in files.",
    )
    parser.add_argument("files", nargs="+", help="files to count")
    parsed = parser.parse_args(args)
    for path in parsed.files:
        print(f"{line_count(path)}\t{path}")


# -- File operations -----------------------------------------------------------


def _handle_clone(args: list[str]) -> None:
    import argparse

    parser = argparse.ArgumentParser(
        prog="clone",
        description="Clone directory contents using rsync.",
    )
    parser.add_argument("source", help="source directory")
    parser.add_argument("target", help="target directory")
    parsed = parser.parse_args(args)
    source = os.path.realpath(parsed.source).rstrip("/")
    target = os.path.realpath(parsed.target).rstrip("/")
    if not os.path.isdir(source):
        msg = f"Source directory does not exist: {source}"
        raise SystemExit(msg)
    if not os.path.isdir(target):
        msg = f"Target directory does not exist: {target}"
        raise SystemExit(msg)
    print(f"Source: {source}", file=sys.stderr)
    print(f"Target: {target}", file=sys.stderr)
    rsync = _which("rsync")
    subprocess.run(
        [rsync, "--archive", "--delete-before", source + "/", target + "/"],
        check=True,
    )


def _handle_delete_broken_symlinks(args: list[str]) -> None:
    import argparse

    from koopa.file_ops import delete_broken_symlinks

    parser = argparse.ArgumentParser(
        prog="delete-broken-symlinks",
        description="Delete broken symlinks.",
    )
    parser.add_argument("dirs", nargs="+", help="directories to scan")
    parsed = parser.parse_args(args)
    for d in parsed.dirs:
        delete_broken_symlinks(d)


def _handle_delete_empty_dirs(args: list[str]) -> None:
    import argparse

    from koopa.file_ops import delete_empty_dirs

    parser = argparse.ArgumentParser(
        prog="delete-empty-dirs",
        description="Delete empty directories.",
    )
    parser.add_argument("dirs", nargs="+", help="directories to scan")
    parsed = parser.parse_args(args)
    for d in parsed.dirs:
        delete_empty_dirs(d)


def _handle_delete_named_subdirs(args: list[str]) -> None:
    import argparse

    from koopa.file_ops import delete_named_subdirs

    parser = argparse.ArgumentParser(
        prog="delete-named-subdirs",
        description="Delete subdirectories matching a name.",
    )
    parser.add_argument("directory", help="parent directory to scan")
    parser.add_argument("name", help="subdirectory name to delete")
    parsed = parser.parse_args(args)
    deleted = delete_named_subdirs(parsed.directory, parsed.name)
    for d in deleted:
        print(d)


def _handle_file_count(args: list[str]) -> None:
    import argparse

    from koopa.file_ops import file_count

    parser = argparse.ArgumentParser(
        prog="file-count",
        description="Count files in a directory.",
    )
    parser.add_argument("directory", help="directory to count")
    parsed = parser.parse_args(args)
    print(file_count(parsed.directory))


def _handle_find_broken_symlinks(args: list[str]) -> None:
    import argparse

    from koopa.file_ops import find_broken_symlinks

    parser = argparse.ArgumentParser(
        prog="find-broken-symlinks",
        description="Find broken symlinks.",
    )
    parser.add_argument("dirs", nargs="+", help="directories to scan")
    parsed = parser.parse_args(args)
    for d in parsed.dirs:
        for link in find_broken_symlinks(d):
            print(link)


def _handle_find_empty_dirs(args: list[str]) -> None:
    import argparse

    from koopa.file_ops import find_empty_dirs

    parser = argparse.ArgumentParser(
        prog="find-empty-dirs",
        description="Find empty directories.",
    )
    parser.add_argument("dirs", nargs="+", help="directories to scan")
    parsed = parser.parse_args(args)
    for d in parsed.dirs:
        for path in find_empty_dirs(d):
            print(path)


def _handle_find_large_dirs(args: list[str]) -> None:
    import argparse

    from koopa.disk import find_large_dirs

    parser = argparse.ArgumentParser(
        prog="find-large-dirs",
        description="Find large directories.",
    )
    parser.add_argument("directory", help="directory to scan")
    parsed = parser.parse_args(args)
    for path, size_mb in find_large_dirs(parsed.directory):
        print(f"{size_mb:.1f}M\t{path}")


def _handle_find_large_files(args: list[str]) -> None:
    import argparse

    from koopa.disk import find_large_files

    parser = argparse.ArgumentParser(
        prog="find-large-files",
        description="Find large files.",
    )
    parser.add_argument("directory", help="directory to scan")
    parsed = parser.parse_args(args)
    for path, size_mb in find_large_files(parsed.directory):
        print(f"{size_mb:.1f}M\t{path}")


def _handle_move_files_in_batch(args: list[str]) -> None:
    import argparse

    parser = argparse.ArgumentParser(
        prog="move-files-in-batch",
        description="Move a batch of files between directories.",
    )
    parser.add_argument("--num", type=int, required=True, help="number of files")
    parser.add_argument("--source-dir", required=True, help="source directory")
    parser.add_argument("--target-dir", required=True, help="target directory")
    parsed = parser.parse_args(args)
    num = parsed.num
    source_dir = parsed.source_dir
    target_dir = parsed.target_dir
    if not os.path.isdir(source_dir):
        msg = f"Source directory does not exist: {source_dir}"
        raise SystemExit(msg)
    Path(target_dir).mkdir(parents=True, exist_ok=True)
    files = sorted(
        os.path.join(source_dir, f)
        for f in os.listdir(source_dir)
        if os.path.isfile(os.path.join(source_dir, f))
    )
    for f in files[:num]:
        dest = os.path.join(target_dir, os.path.basename(f))
        shutil.move(f, dest)
        print(f"{f} -> {dest}", file=sys.stderr)


def _handle_move_files_up_1_level(args: list[str]) -> None:
    import argparse

    parser = argparse.ArgumentParser(
        prog="move-files-up-1-level",
        description="Move files up one directory level.",
    )
    parser.add_argument("directory", nargs="?", default=os.getcwd(), help="directory to process")
    parsed = parser.parse_args(args)
    prefix = os.path.realpath(parsed.directory)
    if not os.path.isdir(prefix):
        msg = f"Directory does not exist: {prefix}"
        raise SystemExit(msg)
    files = []
    for root, _, filenames in os.walk(prefix):
        depth = root.replace(prefix, "").count(os.sep)
        if depth == 1:
            for f in filenames:
                files.append(os.path.join(root, f))
    for f in files:
        dest = os.path.join(prefix, os.path.basename(f))
        shutil.move(f, dest)


def _handle_nfiletypes(args: list[str]) -> None:
    import argparse

    parser = argparse.ArgumentParser(
        prog="nfiletypes",
        description="Count file types in a directory.",
    )
    parser.add_argument("directory", help="directory to scan")
    parsed = parser.parse_args(args)
    prefix = parsed.directory
    if not os.path.isdir(prefix):
        msg = f"Directory does not exist: {prefix}"
        raise SystemExit(msg)
    exts: Counter[str] = Counter()
    for entry in os.scandir(prefix):
        if entry.is_file() and "." in entry.name and not entry.name.startswith("."):
            ext = entry.name.rsplit(".", maxsplit=1)[-1]
            exts[ext] += 1
    for ext, count in sorted(exts.items(), key=lambda x: x[1]):
        print(f"{count}\t{ext}")


# -- Date/move operations ------------------------------------------------------


def _handle_move_into_dated_dirs_by_filename(args: list[str]) -> None:
    import argparse

    parser = argparse.ArgumentParser(
        prog="move-into-dated-dirs-by-filename",
        description="Move files into dated directories based on filename.",
    )
    parser.add_argument("files", nargs="+", help="files to organize")
    parsed = parser.parse_args(args)
    pattern = re.compile(r"^(\d{4})[-_]?(\d{2})[-_]?(\d{2})[-_]?(.+)$")
    for filepath in parsed.files:
        name = os.path.basename(filepath)
        match = pattern.match(name)
        if not match:
            msg = f"Does not contain date: '{filepath}'"
            raise SystemExit(msg)
        year, month, day = match.group(1), match.group(2), match.group(3)
        subdir = os.path.join(year, month, day)
        Path(subdir).mkdir(parents=True, exist_ok=True)
        dest = os.path.join(subdir, name)
        shutil.move(filepath, dest)


def _handle_move_into_dated_dirs_by_timestamp(args: list[str]) -> None:
    import argparse

    parser = argparse.ArgumentParser(
        prog="move-into-dated-dirs-by-timestamp",
        description="Move files into dated directories based on timestamp.",
    )
    parser.add_argument("files", nargs="+", help="files to organize")
    parsed = parser.parse_args(args)
    for filepath in parsed.files:
        mtime = os.path.getmtime(filepath)
        dt = datetime.fromtimestamp(mtime, tz=UTC)
        subdir = f"{dt.year:04d}/{dt.month:02d}/{dt.day:02d}"
        Path(subdir).mkdir(parents=True, exist_ok=True)
        dest = os.path.join(subdir, os.path.basename(filepath))
        shutil.move(filepath, dest)


# -- Archive operations --------------------------------------------------------


def _handle_extract(args: list[str]) -> None:
    import argparse

    from koopa.archive import extract

    parser = argparse.ArgumentParser(
        prog="extract",
        description="Extract archives.",
    )
    parser.add_argument("files", nargs="+", help="archives to extract")
    parsed = parser.parse_args(args)
    for path in parsed.files:
        extract(path)


def _handle_extract_all(args: list[str]) -> None:
    import argparse

    from koopa.archive import extract

    parser = argparse.ArgumentParser(
        prog="extract-all",
        description="Extract all archives.",
    )
    parser.add_argument("files", nargs="+", help="archives to extract")
    parsed = parser.parse_args(args)
    for path in parsed.files:
        extract(path)


def _handle_tar_multiple_dirs(args: list[str]) -> None:
    import argparse

    from koopa.archive import tar_multiple_dirs

    parser = argparse.ArgumentParser(
        prog="tar-multiple-dirs",
        description="Create tar archives for multiple directories.",
    )
    group = parser.add_mutually_exclusive_group()
    group.add_argument(
        "--delete",
        action="store_true",
        help="delete source directories after archiving",
    )
    group.add_argument(
        "--no-delete",
        "--keep",
        action="store_true",
        help="keep source directories (default)",
    )
    parser.add_argument("dirs", nargs="+", help="directories to archive")
    parsed = parser.parse_args(args)
    for d in parsed.dirs:
        if not os.path.isdir(d):
            msg = f"Not a directory: {d}"
            raise SystemExit(msg)
    archives = tar_multiple_dirs(parsed.dirs)
    if parsed.delete:
        for d in parsed.dirs:
            shutil.rmtree(d)
    for a in archives:
        print(a, file=sys.stderr)


# -- Download operations -------------------------------------------------------


def _handle_download(args: list[str]) -> None:
    import argparse

    from koopa.download import download

    parser = argparse.ArgumentParser(
        prog="download",
        description="Download a file from a URL.",
    )
    parser.add_argument("url", help="URL to download")
    parser.add_argument("output", nargs="?", default=None, help="output path")
    parsed = parser.parse_args(args)
    result = download(parsed.url, parsed.output)
    print(result, file=sys.stderr)


def _handle_download_cran_latest(args: list[str]) -> None:
    import argparse

    from koopa.download import download_cran_latest

    parser = argparse.ArgumentParser(
        prog="download-cran-latest",
        description="Download latest CRAN package source.",
    )
    parser.add_argument("packages", nargs="+", help="CRAN package names")
    parsed = parser.parse_args(args)
    for pkg in parsed.packages:
        result = download_cran_latest(pkg)
        print(result, file=sys.stderr)


def _handle_download_github_latest(args: list[str]) -> None:
    import argparse

    from koopa.download import download_github_latest

    parser = argparse.ArgumentParser(
        prog="download-github-latest",
        description="Download latest GitHub release asset.",
    )
    parser.add_argument("--pattern", default=None, help="filename pattern to match")
    parser.add_argument("repo", help="GitHub repository (owner/name)")
    parsed = parser.parse_args(args)
    result = download_github_latest(parsed.repo, pattern=parsed.pattern)
    print(result, file=sys.stderr)


# -- Rename operations ---------------------------------------------------------


def _syntactic_rename(parsed: argparse.Namespace, *, fun: str) -> None:
    try:
        from syntactic import syntactic_rename
    except ImportError:
        msg = "Package 'syntactic' is not installed."
        raise SystemExit(msg) from None
    syntactic_rename(
        parsed.paths,
        fun=fun,
        recursive=parsed.recursive,
        quiet=parsed.quiet,
        dry_run=parsed.dry_run,
        lowercase_ext=parsed.lowercase_ext,
    )


def _syntactic_rename_parser(prog: str, description: str) -> argparse.ArgumentParser:
    import argparse

    parser = argparse.ArgumentParser(prog=prog, description=description)
    parser.add_argument("--recursive", action="store_true", help="process recursively")
    parser.add_argument("--quiet", action="store_true", help="suppress output")
    parser.add_argument("--dry-run", action="store_true", help="show renames only")
    parser.add_argument(
        "--lowercase-ext", action="store_true", help="also convert file extension to lowercase"
    )
    parser.add_argument("paths", nargs="+", help="paths to rename")
    return parser


def _handle_rename_camel_case(args: list[str]) -> None:
    parser = _syntactic_rename_parser("rename-camel-case", "Rename files to camelCase.")
    _syntactic_rename(parser.parse_args(args), fun="camel_case")


def _handle_rename_kebab_case(args: list[str]) -> None:
    parser = _syntactic_rename_parser("rename-kebab-case", "Rename files to kebab-case.")
    _syntactic_rename(parser.parse_args(args), fun="kebab_case")


def _handle_rename_snake_case(args: list[str]) -> None:
    parser = _syntactic_rename_parser("rename-snake-case", "Rename files to snake_case.")
    _syntactic_rename(parser.parse_args(args), fun="snake_case")


def _handle_rename_lowercase(args: list[str]) -> None:
    import argparse

    parser = argparse.ArgumentParser(
        prog="rename-lowercase",
        description="Rename files to lowercase.",
    )
    parser.add_argument("--recursive", action="store_true", help="process directories recursively")
    parser.add_argument("paths", nargs="*", help="paths to process")
    parsed = parser.parse_args(args)
    if not parsed.recursive and not parsed.paths:
        parser.error("paths are required when --recursive is not used")
    recursive = parsed.recursive
    if recursive:
        prefix = parsed.paths[0] if parsed.paths else "."
        for root, dirs, files in os.walk(prefix, topdown=False):
            for name in files + dirs:
                lower = name.lower()
                if lower != name:
                    src = os.path.join(root, name)
                    dst = os.path.join(root, lower)
                    os.rename(src, dst)
    else:
        for path in parsed.paths:
            dn = os.path.dirname(path)
            bn = os.path.basename(path)
            lower = bn.lower()
            if lower != bn:
                os.rename(path, os.path.join(dn, lower))


def _handle_rename_from_csv(args: list[str]) -> None:
    import argparse

    parser = argparse.ArgumentParser(
        prog="rename-from-csv",
        description="Rename files according to a CSV mapping.",
    )
    parser.add_argument("csv_file", help="CSV file with old,new columns")
    parsed = parser.parse_args(args)
    csv_path = parsed.csv_file
    if not csv_path.endswith(".csv"):
        msg = f"Expected CSV file: {csv_path}"
        raise SystemExit(msg)
    with open(csv_path) as f:
        reader = csv.reader(f)
        for row in reader:
            if len(row) >= 2:
                src, dst = row[0], row[1]
                shutil.move(src, dst)


# -- Disk/network operations ---------------------------------------------------


def _handle_df2(args: list[str]) -> None:
    import argparse

    parser = argparse.ArgumentParser(
        prog="df2",
        description="Wrapper around df with improved defaults.",
    )
    parser.add_argument("args", nargs=argparse.REMAINDER, help="additional arguments passed to df")
    parsed = parser.parse_args(args)
    df = _which("df")
    cmd = [df]
    if sys.platform == "linux":
        cmd.extend(["--portability", "--print-type", "--si"])
    else:
        cmd.extend(["-h"])
    cmd.extend(parsed.args)
    subprocess.run(cmd, check=True)


def _handle_ip_address(args: list[str]) -> None:
    import argparse

    parser = argparse.ArgumentParser(
        prog="ip-address",
        description="Print IP address.",
    )
    group = parser.add_mutually_exclusive_group()
    group.add_argument("--local", action="store_true", help="print local IP address")
    group.add_argument("--public", action="store_true", help="print public IP address (default)")
    parsed = parser.parse_args(args)
    mode = "local" if parsed.local else "public"
    if mode == "local":
        hostname = socket.gethostname()
        addr = socket.gethostbyname(hostname)
        print(addr)
    else:
        dig = shutil.which("dig")
        if dig is not None:
            result = subprocess.run(
                [dig, "+short", "myip.opendns.com", "@resolver1.opendns.com", "-4"],
                capture_output=True,
                text=True,
                check=False,
            )
            if result.returncode == 0 and result.stdout.strip():
                print(result.stdout.strip())
                return
        with urllib.request.urlopen("https://ipecho.net/plain") as resp:
            print(resp.read().decode().strip())


def _handle_ip_info(args: list[str]) -> None:
    import argparse

    parser = argparse.ArgumentParser(
        prog="ip-info",
        description="Print public IP information.",
    )
    parser.parse_args(args)
    with urllib.request.urlopen("https://ipinfo.io") as resp:
        print(resp.read().decode().strip())


def _handle_merge_pdf(args: list[str]) -> None:
    import argparse

    parser = argparse.ArgumentParser(
        prog="merge-pdf",
        description="Merge PDF files.",
    )
    parser.add_argument("files", nargs="+", help="PDF files to merge")
    parsed = parser.parse_args(args)
    for f in parsed.files:
        if not os.path.isfile(f):
            msg = f"File not found: {f}"
            raise SystemExit(msg)
    gs = _which("gs")
    subprocess.run(
        [
            gs,
            "-dBATCH",
            "-dNOPAUSE",
            "-q",
            "-sDEVICE=pdfwrite",
            "-sOutputFile=merge.pdf",
            *parsed.files,
        ],
        check=True,
    )


# -- Search operations ---------------------------------------------------------


def _handle_rg_sort(args: list[str]) -> None:
    import argparse

    parser = argparse.ArgumentParser(
        prog="rg-sort",
        description="Run ripgrep with results sorted by path.",
    )
    parser.add_argument("pattern", help="search pattern")
    parsed = parser.parse_args(args)
    rg = _which("rg")
    subprocess.run(
        [rg, "--pretty", "--sort", "path", parsed.pattern],
        check=False,
    )


def _handle_rg_unique(args: list[str]) -> None:
    import argparse

    parser = argparse.ArgumentParser(
        prog="rg-unique",
        description="Run ripgrep and return unique matches.",
    )
    parser.add_argument("pattern", help="search pattern")
    parsed = parser.parse_args(args)
    rg = _which("rg")
    sort_cmd = _which("sort")
    rg_proc = subprocess.Popen(
        [
            rg,
            "--no-filename",
            "--no-line-number",
            "--only-matching",
            "--sort",
            "none",
            parsed.pattern,
        ],
        stdout=subprocess.PIPE,
    )
    subprocess.run(
        [sort_cmd, "--unique"],
        stdin=rg_proc.stdout,
        check=False,
    )
    rg_proc.wait()


# -- Misc operations -----------------------------------------------------------


def _handle_convert_utf8_nfd_to_nfc(args: list[str]) -> None:
    import argparse

    parser = argparse.ArgumentParser(
        prog="convert-utf8-nfd-to-nfc",
        description="Convert UTF-8 NFD filenames to NFC.",
    )
    parser.add_argument("paths", nargs="+", help="paths to process")
    parsed = parser.parse_args(args)
    convmv = _which("convmv")
    subprocess.run(
        [convmv, "-r", "-f", "utf8", "-t", "utf8", "--nfc", "--notest", *parsed.paths],
        check=True,
    )


def _handle_dot_clean(args: list[str]) -> None:
    import argparse

    parser = argparse.ArgumentParser(
        prog="dot-clean",
        description="Remove dot files and macOS cruft.",
    )
    parser.add_argument("directory", help="directory to clean")
    parsed = parser.parse_args(args)
    prefix = os.path.realpath(parsed.directory)
    if not os.path.isdir(prefix):
        msg = f"Directory does not exist: {prefix}"
        raise SystemExit(msg)
    if sys.platform == "darwin":
        dot_clean = shutil.which("dot_clean")
        if dot_clean is not None:
            subprocess.run([dot_clean, prefix], check=True)
    junk_names = {".AppleDouble", ".DS_Store", ".Rhistory", ".lacie"}
    cruft = []
    for root, dirs, files in os.walk(prefix):
        for name in files + dirs:
            full = os.path.join(root, name)
            if not os.path.exists(full) and not os.path.islink(full):
                continue
            if name in junk_names or name.startswith("._"):
                print(f"Removing: {full}", file=sys.stderr)
                if os.path.isdir(full):
                    shutil.rmtree(full)
                else:
                    os.remove(full)
            elif name.startswith("."):
                cruft.append(full)
    if cruft:
        print(f"Dot files remaining in '{prefix}':", file=sys.stderr)
        for c in cruft:
            print(c)
        sys.exit(1)


def _handle_find_and_move_in_sequence(args: list[str]) -> None:
    import argparse

    parser = argparse.ArgumentParser(
        prog="find-and-move-in-sequence",
        description="Find and move files in sequence (not yet implemented).",
    )
    parser.parse_args(args)
    msg = "Not yet implemented."
    raise NotImplementedError(msg)


def _handle_jekyll_serve(args: list[str]) -> None:
    import argparse

    parser = argparse.ArgumentParser(
        prog="jekyll-serve",
        description="Serve a Jekyll website locally.",
    )
    parser.add_argument("directory", nargs="?", default=os.getcwd(), help="site directory")
    parsed = parser.parse_args(args)
    prefix = os.path.realpath(parsed.directory)
    if not os.path.isdir(prefix):
        msg = f"Directory does not exist: {prefix}"
        raise SystemExit(msg)
    bundle = _which("bundle")
    gemfile = os.path.join(prefix, "Gemfile")
    if not os.path.isfile(gemfile):
        msg = f"Gemfile not found in '{prefix}'."
        raise FileNotFoundError(msg)
    xdg_data = os.environ.get(
        "XDG_DATA_HOME",
        os.path.join(os.path.expanduser("~"), ".local", "share"),
    )
    gem_prefix = os.path.join(xdg_data, "gem")
    print(f"Serving Jekyll website in '{prefix}'.", file=sys.stderr)
    lockfile = os.path.join(prefix, "Gemfile.lock")
    if os.path.isfile(lockfile):
        os.remove(lockfile)
    subprocess.run(
        [bundle, "config", "set", "--local", "path", gem_prefix],
        cwd=prefix,
        check=True,
    )
    subprocess.run([bundle, "install"], cwd=prefix, check=True)
    try:
        subprocess.run([bundle, "exec", "jekyll", "serve"], cwd=prefix, check=True)
    finally:
        lockfile = os.path.join(prefix, "Gemfile.lock")
        if os.path.isfile(lockfile):
            os.remove(lockfile)


# -- Dispatch table ------------------------------------------------------------


_HANDLERS: dict[str, Callable[[list[str]], None]] = {
    "autopad-zeros": _handle_autopad_zeros,
    "clone": _handle_clone,
    "convert-utf8-nfd-to-nfc": _handle_convert_utf8_nfd_to_nfc,
    "delete-broken-symlinks": _handle_delete_broken_symlinks,
    "delete-empty-dirs": _handle_delete_empty_dirs,
    "delete-named-subdirs": _handle_delete_named_subdirs,
    "detab": _handle_detab,
    "df2": _handle_df2,
    "dot-clean": _handle_dot_clean,
    "download": _handle_download,
    "download-cran-latest": _handle_download_cran_latest,
    "download-github-latest": _handle_download_github_latest,
    "entab": _handle_entab,
    "eol-lf": _handle_eol_lf,
    "extract": _handle_extract,
    "extract-all": _handle_extract_all,
    "file-count": _handle_file_count,
    "find-and-move-in-sequence": _handle_find_and_move_in_sequence,
    "find-and-replace": _handle_find_and_replace,
    "find-broken-symlinks": _handle_find_broken_symlinks,
    "find-empty-dirs": _handle_find_empty_dirs,
    "find-files-without-line-ending": _handle_find_files_without_line_ending,
    "find-large-dirs": _handle_find_large_dirs,
    "find-large-files": _handle_find_large_files,
    "ip-address": _handle_ip_address,
    "ip-info": _handle_ip_info,
    "jekyll-serve": _handle_jekyll_serve,
    "line-count": _handle_line_count,
    "merge-pdf": _handle_merge_pdf,
    "move-files-in-batch": _handle_move_files_in_batch,
    "move-files-up-1-level": _handle_move_files_up_1_level,
    "move-into-dated-dirs-by-filename": _handle_move_into_dated_dirs_by_filename,
    "move-into-dated-dirs-by-timestamp": _handle_move_into_dated_dirs_by_timestamp,
    "nfiletypes": _handle_nfiletypes,
    "rename-camel-case": _handle_rename_camel_case,
    "rename-from-csv": _handle_rename_from_csv,
    "rename-kebab-case": _handle_rename_kebab_case,
    "rename-lowercase": _handle_rename_lowercase,
    "rename-snake-case": _handle_rename_snake_case,
    "rg-sort": _handle_rg_sort,
    "rg-unique": _handle_rg_unique,
    "sort-lines": _handle_sort_lines,
    "tar-multiple-dirs": _handle_tar_multiple_dirs,
}


def main() -> None:
    """Entry point for bin/ script dispatch."""
    if len(sys.argv) < 2:
        print("Usage: python -m koopa.cli_bin <script-name> [args...]", file=sys.stderr)
        sys.exit(1)
    script_name = sys.argv[1]
    args = sys.argv[2:]
    handler = _HANDLERS.get(script_name)
    if handler is None:
        print(f"Unknown script: {script_name}", file=sys.stderr)
        sys.exit(1)
    try:
        handler(args)
    except KeyboardInterrupt:
        print("\nInterrupted.", file=sys.stderr)
        sys.exit(130)
    except SystemExit as exc:
        if isinstance(exc.code, int):
            sys.exit(exc.code)
        print(f"Error: {exc}", file=sys.stderr)
        sys.exit(1)
    except NotImplementedError as exc:
        print(f"Error: {exc}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
