"""Dispatch table for ``koopa develop`` subcommands.

Replaces the 34-line ``_koopa_cli_develop`` Bash function.
"""

from __future__ import annotations

import os
import shutil
import subprocess
import sys
import tempfile


def _handle_prune_app_binaries() -> None:
    """Handle ``koopa develop prune-app-binaries``."""
    from koopa.app import prune_app_binaries

    prune_app_binaries()


def _handle_format_app_json() -> None:
    """Handle ``koopa develop format-app-json``."""
    import json
    from pathlib import Path

    from koopa.prefix import koopa_prefix

    json_path = Path(koopa_prefix()) / "etc" / "koopa" / "app.json"
    data = json.loads(json_path.read_text())
    sorted_data = dict(sorted(data.items()))
    for key, value in sorted_data.items():
        if isinstance(value, dict):
            sorted_data[key] = dict(sorted(value.items()))
    json_path.write_text(json.dumps(sorted_data, indent=2, ensure_ascii=False) + "\n")


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
    from koopa.prefix import bash_prefix, koopa_prefix, sh_prefix, zsh_prefix

    def _cache_functions_dirs(target_file: str, source_prefix: str) -> None:
        if not os.path.isdir(source_prefix):
            msg = f"Source prefix not found: '{source_prefix}'."
            raise FileNotFoundError(msg)
        if "/bash/" in target_file:
            shebang = "#!/usr/bin/env bash"
        else:
            shebang = "#!/bin/sh"
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
    from koopa.prefix import opt_prefix
    from koopa.system import arch2, os_string

    aws = shutil.which("aws")
    tar = shutil.which("tar")
    if aws is None:
        msg = "aws CLI is not installed."
        raise RuntimeError(msg)
    if tar is None:
        msg = "tar is not installed."
        raise RuntimeError(msg)
    architecture = arch2()
    os_str = os_string()
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


def handle_develop(remainder: list[str]) -> None:
    """Dispatch ``koopa develop ...`` commands."""
    if not remainder:
        print("Error: no develop command specified.", file=sys.stderr)
        sys.exit(1)
    if remainder[-1] in ("--help", "-h"):
        from koopa.cli_help import show_man_page

        show_man_page("develop", *remainder[:-1])
        return
    subcmd = remainder[0]
    rest = remainder[1:]
    if subcmd == "prune-app-binaries":
        _handle_prune_app_binaries()
        return
    if subcmd == "format-app-json":
        _handle_format_app_json()
        return
    if subcmd == "log":
        _handle_view_latest_tmp_log_file()
        return
    if subcmd == "cache-functions":
        _handle_cache_functions()
        return
    if subcmd == "edit-app-json":
        _handle_edit_app_json()
        return
    if subcmd == "push-all-app-builds":
        _handle_push_all_app_builds()
        return
    if subcmd == "push-app-build":
        _handle_push_app_build(rest)
        return
    if subcmd == "roff":
        _handle_roff()
        return
    print(f"Error: unknown develop command '{subcmd}'.", file=sys.stderr)
    sys.exit(1)
