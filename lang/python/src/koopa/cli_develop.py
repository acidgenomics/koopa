"""Dispatch table for ``koopa develop`` subcommands.

Replaces the 34-line ``_koopa_cli_develop`` Bash function.
"""

from __future__ import annotations

import os
import shutil
import subprocess
import sys
import tempfile
from collections.abc import Callable


def _handle_prune_app_binaries() -> None:
    """Handle ``koopa develop prune-app-binaries``."""
    from koopa.app import prune_app_binaries

    prune_app_binaries()


def _handle_format_app_json() -> None:
    """Handle ``koopa develop format-app-json``."""
    from koopa.io import export_app_json, import_app_json

    data = import_app_json()
    export_app_json(data)


def _handle_view_latest_tmp_log_file() -> None:
    """Handle ``koopa develop log`` (view latest tmp log file)."""
    import glob

    from koopa.alert import alert

    tmp_dir = os.environ.get("TMPDIR", "/tmp")
    uid = os.getuid()
    pattern = os.path.join(tmp_dir, f"koopa-{uid}-*")
    files = sorted(glob.glob(pattern))
    if not files:
        print(
            f"Error: No koopa log file detected in '{tmp_dir}'.",
            file=sys.stderr,
        )
        sys.exit(1)
    log_file = files[-1]
    if not os.path.isfile(log_file):
        print(
            f"Error: No koopa log file detected in '{tmp_dir}'.",
            file=sys.stderr,
        )
        sys.exit(1)
    alert(f"Viewing '{log_file}'.")
    pager = os.environ.get("PAGER", "less")
    pager_cmd = shutil.which(pager)
    if pager_cmd is None:
        pager_cmd = shutil.which("less") or shutil.which("more") or "cat"
    if "less" in os.path.basename(pager_cmd):
        subprocess.run([pager_cmd, "+G", log_file], check=False)
    else:
        subprocess.run([pager_cmd, log_file], check=False)


def _handle_cache_functions() -> None:
    """Handle ``koopa develop cache-functions``.

    Caches shell function definitions by concatenating .sh files and
    stripping comments.
    """
    import re

    from koopa.alert import alert
    from koopa.prefix import bash_prefix, sh_prefix, zsh_prefix

    def _cache_functions_dirs(target_file: str, source_prefix: str) -> None:
        if not os.path.isdir(source_prefix):
            msg = f"Source prefix not found: '{source_prefix}'."
            raise FileNotFoundError(msg)
        shebang = "#!/usr/bin/env bash" if "/bash/" in target_file else "#!/bin/sh"
        alert(f"Caching functions in '{target_file}'.")
        sh_files: list[str] = []
        for root, _dirs, files in os.walk(source_prefix):
            for f in files:
                if f.endswith(".sh"):
                    sh_files.append(os.path.join(root, f))
        sh_files.sort()
        comment_re = re.compile(r"^(\s+)?#", re.IGNORECASE)
        os.makedirs(os.path.dirname(target_file), exist_ok=True)
        with open(target_file, "w") as out:
            out.write(shebang + "\n")
            out.write("# shellcheck disable=all\n")
            prev_blank = False
            for sh_file in sh_files:
                with open(sh_file) as fh:
                    for line in fh:
                        if comment_re.match(line):
                            continue
                        is_blank = line.strip() == ""
                        if is_blank and prev_blank:
                            continue
                        out.write(line)
                        prev_blank = is_blank

    bp = bash_prefix()
    sp = sh_prefix()
    zp = zsh_prefix()
    _cache_functions_dirs(
        os.path.join(bp, "include", "functions.sh"),
        os.path.join(bp, "functions"),
    )
    _cache_functions_dirs(
        os.path.join(sp, "include", "functions.sh"),
        os.path.join(sp, "functions"),
    )
    _cache_functions_dirs(
        os.path.join(zp, "include", "functions.sh"),
        os.path.join(zp, "functions"),
    )


def _handle_edit_app_json() -> None:
    """Handle ``koopa develop edit-app-json``."""
    from koopa.prefix import koopa_prefix

    editor = os.environ.get("EDITOR", "vim")
    editor_cmd = shutil.which(editor)
    if editor_cmd is None:
        msg = f"Editor '{editor}' is not installed."
        raise RuntimeError(msg)
    json_file = os.path.join(koopa_prefix(), "etc", "koopa", "app.json")
    if not os.path.isfile(json_file):
        msg = f"File not found: '{json_file}'."
        raise FileNotFoundError(msg)
    subprocess.run([editor_cmd, json_file], check=True)


def _handle_push_app_build(args: list[str]) -> None:
    """Handle ``koopa develop push-app-build <name>...``."""
    if not args:
        print(
            "Usage: koopa develop push-app-build <name>...",
            file=sys.stderr,
        )
        sys.exit(1)
    from koopa.alert import alert, alert_note
    from koopa.install import _os_string
    from koopa.prefix import opt_prefix
    from koopa.system import arch2

    aws = shutil.which("aws")
    tar = shutil.which("tar")
    if aws is None:
        msg = "aws CLI is not installed."
        raise RuntimeError(msg)
    if tar is None:
        msg = "tar is not installed."
        raise RuntimeError(msg)
    architecture = arch2()
    os_str = _os_string()
    prefix = opt_prefix()
    profile = "acidgenomics"
    s3_bucket = "s3://private.koopa.acidgenomics.com/binaries"
    tmp_dir = tempfile.mkdtemp()
    try:
        for name in args:
            app_link = os.path.join(prefix, name)
            app_prefix = os.path.realpath(app_link)
            if not os.path.isdir(app_prefix):
                msg = f"App directory not found: '{app_prefix}'."
                raise FileNotFoundError(msg)
            binary_marker = os.path.join(app_prefix, ".koopa-binary")
            if os.path.isfile(binary_marker):
                alert_note(f"'{name}' was installed as a binary.")
                continue
            version = os.path.basename(app_prefix)
            local_tar_dir = os.path.join(tmp_dir, name)
            os.makedirs(local_tar_dir, exist_ok=True)
            local_tar = os.path.join(local_tar_dir, f"{version}.tar.gz")
            s3_rel = f"/{os_str}/{architecture}/{name}/{version}.tar.gz"
            remote_tar = f"{s3_bucket}{s3_rel}"
            alert(f"Pushing '{app_prefix}' to '{remote_tar}'.")
            alert(f"Creating archive at '{local_tar}'.")
            subprocess.run(
                [tar, "-Pcvvz", "-f", local_tar, f"{app_prefix}/"],
                check=True,
            )
            alert(f"Copying to S3 at '{remote_tar}'.")
            subprocess.run(
                [aws, "s3", f"--profile={profile}", "cp", local_tar, remote_tar],
                check=True,
            )
    finally:
        shutil.rmtree(tmp_dir, ignore_errors=True)


def _handle_push_all_app_builds() -> None:
    """Handle ``koopa develop push-all-app-builds``.

    Finds apps built within the last 7 days and pushes them.
    """
    import time

    from koopa.prefix import opt_prefix

    prefix = opt_prefix()
    if not os.path.isdir(prefix):
        print("Error: No apps installed.", file=sys.stderr)
        sys.exit(1)
    now = time.time()
    seven_days = 7 * 24 * 60 * 60
    app_names: list[str] = []
    try:
        entries = os.listdir(prefix)
    except OSError:
        entries = []
    for entry in sorted(entries):
        full = os.path.join(prefix, entry)
        if not os.path.islink(full):
            continue
        try:
            st = os.lstat(full)
        except OSError:
            continue
        if (now - st.st_mtime) <= seven_days:
            app_names.append(entry)
    if not app_names:
        print("Error: No apps were built recently.", file=sys.stderr)
        sys.exit(1)
    _handle_push_app_build(app_names)


def _handle_roff() -> None:
    """Handle ``koopa develop roff``.

    Finds .ronn files in the man prefix and converts them to roff man pages.
    """
    from koopa.prefix import man_prefix

    ronn = shutil.which("ronn")
    if ronn is None:
        msg = "ronn is not installed."
        raise RuntimeError(msg)
    prefix = man_prefix()
    ronn_files: list[str] = []
    for root, _dirs, files in os.walk(prefix):
        for f in files:
            if f.endswith(".ronn"):
                ronn_files.append(os.path.join(root, f))
    ronn_files.sort()
    if not ronn_files:
        print("Error: No .ronn files found.", file=sys.stderr)
        sys.exit(1)
    subprocess.run([ronn, "--roff", *ronn_files], check=True)


def _collect_shell_files() -> dict[str, list[str]]:
    """Collect shell files grouped by shell type (posix, bash, zsh).

    Searches functions/ subdirectories and include/ files across all lang/
    shell prefixes. Shell type is determined by shebang line.
    """
    from koopa.prefix import bash_prefix, sh_prefix, zsh_prefix

    search_dirs = [
        os.path.join(sh_prefix(), "functions"),
        os.path.join(bash_prefix(), "functions"),
        os.path.join(zsh_prefix(), "functions"),
        os.path.join(sh_prefix(), "include"),
        os.path.join(bash_prefix(), "include"),
        os.path.join(zsh_prefix(), "include"),
    ]
    posix: list[str] = []
    bash: list[str] = []
    zsh: list[str] = []
    for search_dir in search_dirs:
        if not os.path.isdir(search_dir):
            continue
        for root, _dirs, files in os.walk(search_dir):
            for f in sorted(files):
                if not f.endswith(".sh"):
                    continue
                path = os.path.join(root, f)
                try:
                    with open(path, errors="replace") as fh:
                        first_line = fh.readline().rstrip()
                except OSError:
                    continue
                if first_line in ("#!/bin/sh", "#!/usr/bin/env sh"):
                    posix.append(path)
                elif "bash" in first_line:
                    bash.append(path)
                elif "zsh" in first_line:
                    zsh.append(path)
                else:
                    # No shebang or unknown — treat as posix
                    posix.append(path)
    return {"posix": sorted(posix), "bash": sorted(bash), "zsh": sorted(zsh)}


# Illegal patterns that apply to ALL shell files regardless of shell.
_ILLEGAL_ALL = [
    (r"; do\b", "use newline before 'do'"),
    (r"; then\b", "use newline before 'then'"),
    (r"\$path\b", "$path conflicts with zsh PATH array"),
    (r"(?m)^path=", "path= at line start conflicts with zsh PATH array"),
    (r"[\u2018\u2019\u201c\u201d]", "unicode/curly quotes detected"),
    (r"\b(EOF|EOL)\b", "use END instead of EOF/EOL for heredocs"),
]

# Additional illegal patterns for POSIX (#!/bin/sh) files only.
_ILLEGAL_POSIX = [
    (r" == ", "use = not == in POSIX [ ] tests"),
    (r" \[\[ ", "bash-only [[ in POSIX script"),
    (r" \]\]", "bash-only ]] in POSIX script"),
    (r"\[@\]\}", "bash array syntax in POSIX script"),
    (r"(?m)^\[\[ ", "bash-only [[ at start of line in POSIX script"),
]

# Additional illegal patterns for BASH files only.
_ILLEGAL_BASH = [
    (r"(?<!\[)\[ [^\[]", "use [[ ]] instead of [ ] in bash"),
    (r"\[\[ [^=!<>]+ = [^=][^\]]*\]\]", "use == not = in bash [[ ]] tests"),
]

# Additional illegal patterns for ZSH files only.
_ILLEGAL_ZSH = [
    (r"(?<!\[)\[ [^\[]", "use [[ ]] instead of [ ] in zsh"),
    (r"\[\[ [^=!<>]+ = [^=][^\]]*\]\]", "use == not = in zsh [[ ]] tests"),
]


def _check_illegal_strings(files: list[str], extra_patterns: list[tuple[str, str]]) -> list[str]:
    """Check files for illegal string patterns. Returns list of error messages."""
    import re

    patterns = [(re.compile(p), msg) for p, msg in _ILLEGAL_ALL + extra_patterns]
    errors: list[str] = []
    for path in files:
        try:
            content = open(path, errors="replace").read()
            lines = content.splitlines()
        except OSError:
            continue
        for lineno, line in enumerate(lines, 1):
            # Skip shellcheck disable comments and comment-only lines.
            stripped = line.lstrip()
            if stripped.startswith("#"):
                continue
            for regex, msg in patterns:
                if regex.search(line):
                    errors.append(f"{path}:{lineno}: {msg}")
                    errors.append(f"  {line.rstrip()}")
    return errors


def _handle_shellcheck() -> None:
    """Handle ``koopa develop shellcheck``."""
    from koopa.alert import alert, alert_note, alert_success

    shellcheck = shutil.which("shellcheck")
    if shellcheck is None:
        msg = "shellcheck is not installed."
        raise RuntimeError(msg)
    by_shell = _collect_shell_files()
    posix_files = by_shell["posix"]
    bash_files = by_shell["bash"]
    zsh_files = by_shell["zsh"]
    all_files = posix_files + bash_files + zsh_files
    if not all_files:
        print("Error: No shell files found to check.", file=sys.stderr)
        sys.exit(1)
    # --- Illegal-string checks (all shells including zsh) ---
    alert(f"Running illegal-string checks on {len(all_files)} files.")
    errors: list[str] = []
    errors += _check_illegal_strings(posix_files, _ILLEGAL_POSIX)
    errors += _check_illegal_strings(bash_files, _ILLEGAL_BASH)
    errors += _check_illegal_strings(zsh_files, _ILLEGAL_ZSH)
    if errors:
        for line in errors:
            print(line, file=sys.stderr)
        sys.exit(1)
    alert_success("Illegal-string checks passed.")
    # --- shellcheck (posix + bash only) ---
    sc_files = sorted(posix_files + bash_files)
    alert(f"Running shellcheck on {len(sc_files)} files.")
    alert_note("shellcheck does not support zsh; skipping lang/zsh/.")
    result = subprocess.run(
        [shellcheck, "--external-sources", *sc_files],
        check=False,
    )
    if result.returncode == 0:
        alert_success(f"shellcheck passed [{len(sc_files)} files].")
    else:
        sys.exit(result.returncode)


def _handle_check_app_versions(args: list[str]) -> None:
    """Handle ``koopa develop check-app-versions``."""
    import argparse

    from koopa.version_check import (
        check_app_versions,
        print_json_report,
        print_report,
        update_app_json,
    )

    parser = argparse.ArgumentParser(
        prog="koopa develop check-app-versions",
        description="Check app versions against upstream sources.",
    )
    parser.add_argument(
        "apps",
        nargs="*",
        help="app names to check (default: all)",
    )
    parser.add_argument(
        "--json",
        action="store_true",
        dest="output_json",
        help="output results as JSON",
    )
    parser.add_argument(
        "--source",
        default=None,
        help="filter by source type (e.g. github, pypi, conda)",
    )
    parser.add_argument(
        "--update",
        action="store_true",
        help="update app.json with latest versions",
    )
    parser.add_argument(
        "--s3-upload",
        action="store_true",
        dest="s3_upload",
        help="upload source tarballs to s3://koopa.acidgenomics.com (requires acidgenomics AWS profile)",
    )
    parser.add_argument(
        "--reset-cache",
        action="store_true",
        help="clear version cache and force fresh lookups",
    )
    parsed = parser.parse_args(args)
    results = check_app_versions(
        source_filter=parsed.source,
        name_filter=parsed.apps or None,
        reset_cache=parsed.reset_cache,
    )
    if parsed.output_json:
        print_json_report(results)
    else:
        print_report(results)
    if parsed.update:
        update_app_json(results, s3_upload=parsed.s3_upload)


def _handle_pytest(args: list[str]) -> None:
    """Handle ``koopa develop pytest``."""
    from koopa.prefix import python_prefix

    tests_dir = os.path.join(python_prefix(), "tests")
    pytest_cmd = shutil.which("pytest")
    if pytest_cmd is None:
        msg = "pytest is not installed."
        raise RuntimeError(msg)
    sys.exit(subprocess.run([pytest_cmd, tests_dir, *args], check=False).returncode)


def _handle_generate_completion() -> None:
    """Handle ``koopa develop generate-completion``."""
    from koopa.alert import alert_note, alert_success
    from koopa.generate_completion import generate_completion

    generate_completion()
    alert_success("Completion file updated.")
    alert_note("Reload your shell to apply changes.")


def _handle_mirror_src(args: list[str]) -> None:
    """Handle ``koopa develop mirror-src [<name>...]``.

    Downloads source tarballs from upstream and uploads to the
    s3://koopa.acidgenomics.com/src/ mirror. With no args, mirrors all
    apps with ``"mirror": true`` in app.json.
    """
    from koopa.io import import_app_json
    from koopa.version_check import _has_acidgenomics_aws, _mirror_src_to_s3

    if not _has_acidgenomics_aws():
        print(
            "Error: 'acidgenomics' AWS profile not found in ~/.aws/credentials.",
            file=sys.stderr,
        )
        sys.exit(1)
    data = import_app_json()
    if args:
        targets = args
        for name in targets:
            if name not in data:
                print(f"Error: '{name}' not found in app.json.", file=sys.stderr)
                sys.exit(1)
            if not data[name].get("src_url"):
                print(f"Error: '{name}' has no 'src_url' in app.json.", file=sys.stderr)
                sys.exit(1)
    else:
        targets = sorted(k for k, v in data.items() if v.get("mirror"))
        if not targets:
            print("Error: No apps with 'mirror: true' found in app.json.", file=sys.stderr)
            sys.exit(1)
    print(f"Mirroring {len(targets)} app(s) to S3.", file=sys.stderr)
    for name in targets:
        entry = data[name]
        version = entry.get("version", "")
        src_url = entry.get("src_url", "")
        if not version or not src_url:
            print(f"  Skipping '{name}': missing version or src_url.", file=sys.stderr)
            continue
        _mirror_src_to_s3(name, version, src_url)


def _handle_audit_src_mirror(args: list[str]) -> None:
    """Handle ``koopa develop audit-src-mirror [<name>...]``.

    Checks which mirror apps have their current source tarball present in
    s3://koopa.acidgenomics.com/src/ using a lightweight head-object call.
    Exits 1 if any are missing.
    """
    import shutil as _shutil

    from koopa.io import import_app_json
    from koopa.version_check import _expand_src_url, _has_acidgenomics_aws

    if not _has_acidgenomics_aws():
        print(
            "Error: 'acidgenomics' AWS profile not found in ~/.aws/credentials.",
            file=sys.stderr,
        )
        sys.exit(1)
    aws = _shutil.which("aws")
    if aws is None:
        print("Error: aws CLI is not installed.", file=sys.stderr)
        sys.exit(1)
    data = import_app_json()
    if args:
        targets = args
        for name in targets:
            if name not in data:
                print(f"Error: '{name}' not found in app.json.", file=sys.stderr)
                sys.exit(1)
    else:
        targets = sorted(k for k, v in data.items() if v.get("mirror"))
        if not targets:
            print("Error: No apps with 'mirror: true' found in app.json.", file=sys.stderr)
            sys.exit(1)
    bucket = "koopa.acidgenomics.com"
    missing: list[str] = []
    for name in targets:
        entry = data[name]
        version = entry.get("version", "")
        src_url = entry.get("src_url", "")
        if not version or not src_url:
            print(f"  skip  {name}: missing version or src_url.", file=sys.stderr)
            continue
        url = _expand_src_url(src_url, version)
        filename = url.rsplit("/", 1)[-1]
        key = f"src/{name}/{filename}"
        result = subprocess.run(
            [
                aws,
                "s3api",
                "head-object",
                "--bucket",
                bucket,
                "--key",
                key,
                "--profile",
                "acidgenomics",
            ],
            capture_output=True,
            check=False,
        )
        if result.returncode == 0:
            print(f"  ok    {name}/{filename}")
        else:
            print(f"  MISS  {name}/{filename}")
            missing.append(name)
    if missing:
        print(
            f"\n{len(missing)} app(s) missing from mirror: {', '.join(missing)}",
            file=sys.stderr,
        )
        sys.exit(1)
    else:
        print(f"\nAll {len(targets)} app(s) present in mirror.")


def _handle_circular_dependencies() -> None:
    """Handle ``koopa develop circular-dependencies``."""
    from koopa.check import check_circular_deps

    cycles = check_circular_deps()
    if not cycles:
        print("No circular dependencies detected.")
        return
    print(f"Found {len(cycles)} circular dependency chain(s):")
    for cycle in cycles:
        print(f"  {' -> '.join(cycle)}")
    sys.exit(1)


_DEVELOP_HANDLERS: dict[str, Callable[[list[str]], None]] = {
    "prune-app-binaries": lambda _: _handle_prune_app_binaries(),
    "format-app-json": lambda _: _handle_format_app_json(),
    "generate-completion": lambda _: _handle_generate_completion(),
    "pytest": _handle_pytest,
    "log": lambda _: _handle_view_latest_tmp_log_file(),
    "cache-functions": lambda _: _handle_cache_functions(),
    "edit-app-json": lambda _: _handle_edit_app_json(),
    "push-all-app-builds": lambda _: _handle_push_all_app_builds(),
    "push-app-build": _handle_push_app_build,
    "roff": lambda _: _handle_roff(),
    "shellcheck": lambda _: _handle_shellcheck(),
    "check-app-versions": _handle_check_app_versions,
    "circular-dependencies": lambda _: _handle_circular_dependencies(),
    "mirror-src": _handle_mirror_src,
    "audit-src-mirror": _handle_audit_src_mirror,
}


def handle_develop(remainder: list[str]) -> None:
    """Dispatch ``koopa develop ...`` commands."""
    if not remainder:
        print("Error: no develop command specified.", file=sys.stderr)
        sys.exit(1)
    subcmd = remainder[0]
    rest = remainder[1:]
    handler = _DEVELOP_HANDLERS.get(subcmd)
    if handler is not None:
        handler(rest)
        return
    print(f"Error: unknown develop command '{subcmd}'.", file=sys.stderr)
    sys.exit(1)
