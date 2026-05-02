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


def _assert_args(args: list[str], *, min_: int = 0, max_: int | None = None) -> None:
    """Validate argument count."""
    if len(args) < min_:
        msg = f"Expected at least {min_} argument(s), got {len(args)}."
        raise SystemExit(msg)
    if max_ is not None and len(args) > max_:
        msg = f"Expected at most {max_} argument(s), got {len(args)}."
        raise SystemExit(msg)


def _parse_key_value_args(
    args: list[str],
    keys: set[str],
    flags: set[str] | None = None,
) -> tuple[dict[str, str], dict[str, bool], list[str]]:
    """Parse --key=value args, --flag args, and positional args."""
    kv: dict[str, str] = {}
    fl: dict[str, bool] = {f: False for f in (flags or set())}
    pos: list[str] = []
    for arg in args:
        if "=" in arg and arg.startswith("--"):
            key, value = arg.split("=", 1)
            key = key.lstrip("-")
            if key in keys:
                kv[key] = value
                continue
        if arg.startswith("--") and arg.lstrip("-") in (flags or set()):
            fl[arg.lstrip("-")] = True
            continue
        pos.append(arg)
    return kv, fl, pos


def _which(name: str) -> str:
    """Locate a command."""
    path = shutil.which(name)
    if path is None:
        msg = f"Command not found: {name}"
        raise FileNotFoundError(msg)
    return path


# -- Text processing -----------------------------------------------------------


def _handle_autopad_zeros(args: list[str]) -> None:
    from koopa.text import autopad_zeros

    _assert_args(args, min_=1, max_=1)
    renames = autopad_zeros(args[0])
    for old, new in renames:
        print(f"{old} -> {new}", file=sys.stderr)


def _handle_detab(args: list[str]) -> None:
    from koopa.text import detab

    _assert_args(args, min_=1)
    for path in args:
        detab(path)


def _handle_entab(args: list[str]) -> None:
    from koopa.text import entab

    _assert_args(args, min_=1)
    for path in args:
        entab(path)


def _handle_eol_lf(args: list[str]) -> None:
    from koopa.text import eol_lf

    _assert_args(args, min_=1)
    for path in args:
        eol_lf(path)


def _handle_find_and_replace(args: list[str]) -> None:
    from koopa.text import find_and_replace_in_file

    _, flags, pos = _parse_key_value_args(
        args,
        keys=set(),
        flags={"fixed", "regex"},
    )
    _assert_args(pos, min_=3)
    pattern = pos[0]
    replacement = pos[1]
    fixed = flags.get("fixed", False)
    for path in pos[2:]:
        find_and_replace_in_file(path, pattern, replacement, fixed=fixed)


def _handle_find_files_without_line_ending(args: list[str]) -> None:
    from koopa.text import find_files_without_line_ending

    _assert_args(args, min_=1, max_=1)
    for path in find_files_without_line_ending(args[0]):
        print(path)


def _handle_sort_lines(args: list[str]) -> None:
    from koopa.text import sort_lines

    _assert_args(args, min_=1)
    for path in args:
        sort_lines(path)


def _handle_line_count(args: list[str]) -> None:
    from koopa.file_ops import line_count

    _assert_args(args, min_=1)
    for path in args:
        print(f"{line_count(path)}\t{path}")


# -- File operations -----------------------------------------------------------


def _handle_clone(args: list[str]) -> None:
    _assert_args(args, min_=2, max_=2)
    source = os.path.realpath(args[0]).rstrip("/")
    target = os.path.realpath(args[1]).rstrip("/")
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
    from koopa.file_ops import delete_broken_symlinks

    _assert_args(args, min_=1)
    for d in args:
        delete_broken_symlinks(d)


def _handle_delete_empty_dirs(args: list[str]) -> None:
    from koopa.file_ops import delete_empty_dirs

    _assert_args(args, min_=1)
    for d in args:
        delete_empty_dirs(d)


def _handle_delete_named_subdirs(args: list[str]) -> None:
    from koopa.file_ops import delete_named_subdirs

    _assert_args(args, min_=2, max_=2)
    deleted = delete_named_subdirs(args[0], args[1])
    for d in deleted:
        print(d)


def _handle_file_count(args: list[str]) -> None:
    from koopa.file_ops import file_count

    _assert_args(args, min_=1, max_=1)
    print(file_count(args[0]))


def _handle_find_broken_symlinks(args: list[str]) -> None:
    from koopa.file_ops import find_broken_symlinks

    _assert_args(args, min_=1)
    for d in args:
        for link in find_broken_symlinks(d):
            print(link)


def _handle_find_empty_dirs(args: list[str]) -> None:
    from koopa.file_ops import find_empty_dirs

    _assert_args(args, min_=1)
    for d in args:
        for path in find_empty_dirs(d):
            print(path)


def _handle_find_large_dirs(args: list[str]) -> None:
    from koopa.disk import find_large_dirs

    _assert_args(args, min_=1, max_=1)
    for path, size_mb in find_large_dirs(args[0]):
        print(f"{size_mb:.1f}M\t{path}")


def _handle_find_large_files(args: list[str]) -> None:
    from koopa.disk import find_large_files

    _assert_args(args, min_=1, max_=1)
    for path, size_mb in find_large_files(args[0]):
        print(f"{size_mb:.1f}M\t{path}")


def _handle_move_files_in_batch(args: list[str]) -> None:
    kv, _, _ = _parse_key_value_args(
        args,
        keys={"num", "source-dir", "target-dir"},
    )
    num = int(kv["num"])
    source_dir = kv["source-dir"]
    target_dir = kv["target-dir"]
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
    prefix = args[0] if args else os.getcwd()
    prefix = os.path.realpath(prefix)
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
    _assert_args(args, min_=1, max_=1)
    prefix = args[0]
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
    _assert_args(args, min_=1)
    pattern = re.compile(r"^(\d{4})[-_]?(\d{2})[-_]?(\d{2})[-_]?(.+)$")
    for filepath in args:
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
    _assert_args(args, min_=1)
    for filepath in args:
        mtime = os.path.getmtime(filepath)
        dt = datetime.fromtimestamp(mtime, tz=UTC)
        subdir = f"{dt.year:04d}/{dt.month:02d}/{dt.day:02d}"
        Path(subdir).mkdir(parents=True, exist_ok=True)
        dest = os.path.join(subdir, os.path.basename(filepath))
        shutil.move(filepath, dest)


# -- Archive operations --------------------------------------------------------


def _handle_extract(args: list[str]) -> None:
    from koopa.archive import extract

    _assert_args(args, min_=1)
    for path in args:
        extract(path)


def _handle_extract_all(args: list[str]) -> None:
    from koopa.archive import extract

    _assert_args(args, min_=1)
    for path in args:
        extract(path)


def _handle_tar_multiple_dirs(args: list[str]) -> None:
    from koopa.archive import tar_multiple_dirs

    _, flags, pos = _parse_key_value_args(
        args,
        keys=set(),
        flags={"delete", "no-delete", "keep"},
    )
    _assert_args(pos, min_=1)
    for d in pos:
        if not os.path.isdir(d):
            msg = f"Not a directory: {d}"
            raise SystemExit(msg)
    archives = tar_multiple_dirs(pos)
    if flags.get("delete", False):
        for d in pos:
            shutil.rmtree(d)
    for a in archives:
        print(a, file=sys.stderr)


# -- Download operations -------------------------------------------------------


def _handle_download(args: list[str]) -> None:
    from koopa.download import download

    _assert_args(args, min_=1, max_=2)
    url = args[0]
    output = args[1] if len(args) > 1 else None
    result = download(url, output)
    print(result, file=sys.stderr)


def _handle_download_cran_latest(args: list[str]) -> None:
    from koopa.download import download_cran_latest

    _assert_args(args, min_=1)
    for pkg in args:
        result = download_cran_latest(pkg)
        print(result, file=sys.stderr)


def _handle_download_github_latest(args: list[str]) -> None:
    from koopa.download import download_github_latest

    kv, _, pos = _parse_key_value_args(args, keys={"pattern"})
    _assert_args(pos, min_=1, max_=1)
    result = download_github_latest(pos[0], pattern=kv.get("pattern"))
    print(result, file=sys.stderr)


# -- Rename operations ---------------------------------------------------------


def _syntactic_rename(args: list[str], *, fun: str) -> None:
    try:
        from syntactic import syntactic_rename
    except ImportError:
        msg = "Package 'syntactic' is not installed."
        raise SystemExit(msg) from None
    _, flags, pos = _parse_key_value_args(
        args,
        keys=set(),
        flags={"recursive", "quiet", "dry-run"},
    )
    _assert_args(pos, min_=1)
    syntactic_rename(
        pos,
        fun=fun,
        recursive=flags.get("recursive", False),
        quiet=flags.get("quiet", False),
        dry_run=flags.get("dry-run", False),
    )


def _handle_rename_camel_case(args: list[str]) -> None:
    _syntactic_rename(args, fun="camel_case")


def _handle_rename_kebab_case(args: list[str]) -> None:
    _syntactic_rename(args, fun="kebab_case")


def _handle_rename_snake_case(args: list[str]) -> None:
    _syntactic_rename(args, fun="snake_case")


def _handle_rename_lowercase(args: list[str]) -> None:
    _, flags, pos = _parse_key_value_args(
        args,
        keys=set(),
        flags={"recursive"},
    )
    recursive = flags.get("recursive", False)
    if recursive:
        prefix = pos[0] if pos else "."
        for root, dirs, files in os.walk(prefix, topdown=False):
            for name in files + dirs:
                lower = name.lower()
                if lower != name:
                    src = os.path.join(root, name)
                    dst = os.path.join(root, lower)
                    os.rename(src, dst)
    else:
        _assert_args(pos, min_=1)
        for path in pos:
            dn = os.path.dirname(path)
            bn = os.path.basename(path)
            lower = bn.lower()
            if lower != bn:
                os.rename(path, os.path.join(dn, lower))


def _handle_rename_from_csv(args: list[str]) -> None:
    _assert_args(args, min_=1, max_=1)
    csv_path = args[0]
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
    df = _which("df")
    cmd = [df]
    if sys.platform == "linux":
        cmd.extend(["--portability", "--print-type", "--si"])
    else:
        cmd.extend(["-h"])
    cmd.extend(args)
    subprocess.run(cmd, check=True)


def _handle_ip_address(args: list[str]) -> None:
    mode = "public"
    for arg in args:
        if arg == "--local":
            mode = "local"
        elif arg == "--public":
            mode = "public"
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
    with urllib.request.urlopen("https://ipinfo.io") as resp:
        print(resp.read().decode().strip())


def _handle_merge_pdf(args: list[str]) -> None:
    _assert_args(args, min_=1)
    for f in args:
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
            *args,
        ],
        check=True,
    )


# -- Search operations ---------------------------------------------------------


def _handle_rg_sort(args: list[str]) -> None:
    _assert_args(args, min_=1, max_=1)
    rg = _which("rg")
    subprocess.run(
        [rg, "--pretty", "--sort", "path", args[0]],
        check=False,
    )


def _handle_rg_unique(args: list[str]) -> None:
    _assert_args(args, min_=1, max_=1)
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
            args[0],
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
    _assert_args(args, min_=1)
    convmv = _which("convmv")
    subprocess.run(
        [convmv, "-r", "-f", "utf8", "-t", "utf8", "--nfc", "--notest", *args],
        check=True,
    )


def _handle_dot_clean(args: list[str]) -> None:
    _assert_args(args, min_=1, max_=1)
    prefix = os.path.realpath(args[0])
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
    msg = "Not yet implemented."
    raise NotImplementedError(msg)


def _handle_jekyll_serve(args: list[str]) -> None:
    prefix = args[0] if args else os.getcwd()
    prefix = os.path.realpath(prefix)
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
    except (SystemExit, NotImplementedError) as exc:
        print(f"Error: {exc}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
