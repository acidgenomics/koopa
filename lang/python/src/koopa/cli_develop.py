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


def _handle_format_app_json(args: list[str]) -> None:
    """Handle ``koopa develop format-app-json``."""
    from koopa.io import export_app_json, import_app_json

    pretty = "--pretty" in args
    data = import_app_json()
    export_app_json(data, pretty=pretty)


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


def _handle_push_app_builds() -> None:
    """Handle ``koopa develop push-app-builds``.

    Checks all installed apps against S3 and pushes any missing builds.
    """
    from koopa.install import _can_push_binary, push_missing_app_builds

    if not _can_push_binary():
        print(
            "Error: push requires KOOPA_BUILDER=1, acidgenomics AWS profile, "
            "AWS_CLOUDFRONT_DISTRIBUTION_ID, and aws CLI.",
            file=sys.stderr,
        )
        sys.exit(1)
    push_missing_app_builds()


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
            with open(path, errors="replace") as _fh:
                content = _fh.read()
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
        help=(
            "upload source tarballs to s3://koopa.acidgenomics.com"
            " (requires acidgenomics AWS profile)"
        ),
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
        import os
        from pathlib import Path

        from koopa.alert import alert_note
        from koopa.install import _install_lock_path

        lock_path = _install_lock_path()
        if os.path.isfile(lock_path):
            pid = -1
            try:
                pid = int(Path(lock_path).read_text().strip())
                os.kill(pid, 0)
                alert_note(
                    f"Cannot update app.json: install in progress (PID {pid}). "
                    "Wait for it to finish or remove "
                    f"'{lock_path}' if the process is stale."
                )
                sys.exit(1)
            except PermissionError:
                # Process exists but owned by another user — still block.
                alert_note(
                    f"Cannot update app.json: install in progress (PID {pid}). "
                    "Wait for it to finish or remove "
                    f"'{lock_path}' if the process is stale."
                )
                sys.exit(1)
            except (ValueError, ProcessLookupError, OSError):
                pass
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


def _mirror_src_cache_path() -> str:
    from koopa.xdg import xdg_cache_home

    return os.path.join(xdg_cache_home(), "koopa", "mirror-src-presence.json")


def _load_mirror_src_cache() -> dict[str, float]:
    import json

    path = _mirror_src_cache_path()
    if not os.path.isfile(path):
        return {}
    try:
        with open(path) as f:
            data = json.load(f)
        return data if isinstance(data, dict) else {}
    except Exception:
        return {}


def _save_mirror_src_cache(cache: dict[str, float]) -> None:
    import json

    path = _mirror_src_cache_path()
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "w") as f:
        json.dump(cache, f, indent=2)


def _handle_mirror_src(args: list[str]) -> None:
    """Handle ``koopa develop mirror-src [<name>...]``.

    Downloads source tarballs from upstream and uploads to the
    s3://koopa.acidgenomics.com/src/ mirror. With no args, mirrors all
    apps with ``"mirror": true`` in app.json.
    """
    import time

    from koopa.io import import_app_json
    from koopa.version_check import _expand_src_url, _has_acidgenomics_aws, _mirror_src_to_s3

    if not _has_acidgenomics_aws():
        print(
            "Error: 'acidgenomics' AWS profile not found in ~/.aws/credentials.",
            file=sys.stderr,
        )
        sys.exit(1)
    aws = shutil.which("aws")
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
            if not data[name].get("src_url"):
                print(f"Error: '{name}' has no 'src_url' in app.json.", file=sys.stderr)
                sys.exit(1)
    else:
        targets = sorted(k for k, v in data.items() if v.get("mirror"))
        if not targets:
            print("Error: No apps with 'mirror: true' found in app.json.", file=sys.stderr)
            sys.exit(1)
    print(f"Mirroring {len(targets)} app(s) to S3.", file=sys.stderr)
    bucket = "koopa.acidgenomics.com"
    cache = _load_mirror_src_cache()
    now = time.time()
    _cache_ttl = 86400  # 24 hours
    failures: dict[str, str] = {}
    for name in targets:
        entry = data[name]
        version = entry.get("version", "")
        src_url = entry.get("src_url", "")
        if not version or not src_url:
            print(f"  Skipping '{name}': missing version or src_url.", file=sys.stderr)
            continue
        url = _expand_src_url(src_url, version)
        filename = url.rsplit("/", 1)[-1]
        cache_key = f"{name}/{filename}"
        if cache_key in cache and (now - cache[cache_key]) < _cache_ttl:
            print(f"  Already present (cached): {cache_key}", file=sys.stderr)
            continue
        key = f"src/{cache_key}"
        head = subprocess.run(
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
        if head.returncode == 0:
            cache[cache_key] = now
            _save_mirror_src_cache(cache)
            print(f"  Already present: {cache_key}", file=sys.stderr)
            continue
        try:
            _mirror_src_to_s3(name, version, src_url, strict=True)
            cache[cache_key] = now
            _save_mirror_src_cache(cache)
        except Exception as exc:
            failures[name] = str(exc)
            print(f"  FAILED: {name}: {exc}", file=sys.stderr)

    if failures:
        print(
            f"\n{len(failures)} app(s) failed to mirror:",
            file=sys.stderr,
        )
        for fname, reason in sorted(failures.items()):
            print(f"  {fname}: {reason}", file=sys.stderr)
        sys.exit(1)


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


def _handle_remove_app(args: list[str]) -> None:
    """Handle ``koopa develop remove-app <name> [--revdeps <app>...]``.

    Tombstones *name* in app.json, increments the ``revision`` counter on all
    reverse dependencies so that ``koopa update`` will automatically rebuild
    them, and deletes the installer file if one exists.

    Run this command BEFORE editing installer files or removing the dep from
    app.json dependency lists so that auto-detection of reverse dependencies
    still works.
    """
    import os
    from datetime import date

    from koopa.app import app_revdeps
    from koopa.io import export_app_json, import_app_json

    if not args or args[0].startswith("-"):
        print("Error: remove-app requires an app name.", file=sys.stderr)
        sys.exit(1)

    name = args[0]
    rest = args[1:]

    # Parse optional --revdeps flag.
    explicit_revdeps: list[str] | None = None
    if rest:
        if rest[0] == "--revdeps":
            explicit_revdeps = rest[1:]
        else:
            print(f"Error: unexpected argument {rest[0]!r}.", file=sys.stderr)
            sys.exit(1)

    data = import_app_json()
    if name not in data:
        print(f"Error: {name!r} not found in app.json.", file=sys.stderr)
        sys.exit(1)
    if data[name].get("removed"):
        print(f"Error: {name!r} is already tombstoned.", file=sys.stderr)
        sys.exit(1)

    # Detect reverse dependencies before modifying the entry.
    revdeps = explicit_revdeps if explicit_revdeps is not None else app_revdeps(name, mode="all")

    # Tombstone the entry: keep url for provenance, strip all install fields.
    entry = data[name]
    tombstone: dict = {"date": str(date.today()), "removed": True}
    if "url" in entry:
        tombstone["url"] = entry["url"]
    data[name] = tombstone

    # Bump revision on every reverse dependency.
    bumped: list[str] = []
    for rd in revdeps:
        if rd not in data:
            print(f"Warning: reverse dep {rd!r} not found in app.json, skipping.", file=sys.stderr)
            continue
        data[rd]["revision"] = data[rd].get("revision", 0) + 1
        bumped.append(rd)

    export_app_json(data)

    # Delete the installer file if it exists.
    pkg_dir = os.path.dirname(os.path.abspath(__file__))
    installer_name = name.replace("-", "_")
    installer_path = os.path.join(pkg_dir, "installers", f"{installer_name}.py")
    deleted_installer = False
    if os.path.isfile(installer_path):
        os.remove(installer_path)
        deleted_installer = True

    # Report.
    print(f"Tombstoned: {name}")
    if deleted_installer:
        print(f"Deleted installer: {installer_path}")
    if bumped:
        print(f"Bumped revision on: {', '.join(bumped)}")
        print(
            "Next steps: remove references to "
            f"{name!r} from the installer file(s) of: {', '.join(bumped)}"
        )
    else:
        print("No reverse dependencies found.")


def _handle_bump_revision(args: list[str]) -> None:
    """Handle ``koopa develop bump-revision <app>...``.

    Increments the ``revision`` field by 1 for each named app in app.json.
    This marks the app as stale so ``koopa update`` will rebuild it.
    """
    from koopa.io import export_app_json, import_app_json

    if not args:
        print("Error: bump-revision requires at least one app name.", file=sys.stderr)
        sys.exit(1)

    data = import_app_json()
    unknown = [a for a in args if a not in data]
    if unknown:
        print(f"Error: unknown apps: {', '.join(unknown)}", file=sys.stderr)
        sys.exit(1)

    for app in args:
        data[app]["revision"] = data[app].get("revision", 0) + 1
        print(f"  {app}: revision -> {data[app]['revision']}")

    export_app_json(data)


def _handle_bump_venv_revision(_: list[str]) -> None:
    """Handle ``koopa develop bump-venv-revision``.

    Increments the venv revision counter in etc/koopa/venv-revision.txt.
    This marks the .venv as stale so ``koopa update`` will reinstall it.
    """
    from koopa.os import koopa_prefix

    revision_file = os.path.join(koopa_prefix(), "etc", "koopa", "venv-revision.txt")
    current = 0
    if os.path.isfile(revision_file):
        with open(revision_file) as f:
            current = int(f.read().strip() or "0")
    new = current + 1
    with open(revision_file, "w") as f:
        f.write(f"{new}\n")
    print(f"  venv-revision: {current} -> {new}")


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


def _handle_update_docs(_: list[str]) -> None:
    """Handle ``koopa develop update-docs``."""
    from koopa.alert import alert_success
    from koopa.update_docs import update_docs

    update_docs()
    alert_success("Documentation updated.")


_DEVELOP_HANDLERS: dict[str, Callable[[list[str]], None]] = {
    "prune-app-binaries": lambda _: _handle_prune_app_binaries(),
    "format-app-json": _handle_format_app_json,
    "update-docs": _handle_update_docs,
    "generate-completion": lambda _: _handle_generate_completion(),
    "pytest": _handle_pytest,
    "log": lambda _: _handle_view_latest_tmp_log_file(),
    "cache-functions": lambda _: _handle_cache_functions(),
    "edit-app-json": lambda _: _handle_edit_app_json(),
    "push-all-app-builds": lambda _: _handle_push_all_app_builds(),
    "push-app-build": _handle_push_app_build,
    "push-app-builds": lambda _: _handle_push_app_builds(),
    "roff": lambda _: _handle_roff(),
    "shellcheck": lambda _: _handle_shellcheck(),
    "check-app-versions": _handle_check_app_versions,
    "circular-dependencies": lambda _: _handle_circular_dependencies(),
    "mirror-src": _handle_mirror_src,
    "audit-src-mirror": _handle_audit_src_mirror,
    "remove-app": _handle_remove_app,
    "bump-revision": _handle_bump_revision,
    "bump-venv-revision": _handle_bump_venv_revision,
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
