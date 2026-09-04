"""Dispatch table for ``koopa develop`` subcommands.

Replaces the 34-line ``_koopa_cli_develop`` Bash function.
"""

import os
import shutil
import subprocess
import sys
import tempfile
from collections.abc import Callable, Iterable, Iterator
from typing import IO, Any, Self, cast


class _TqdmFallback:
    """Minimal progress-bar shim when tqdm is not installed.

    Parameters
    ----------
    iterable : Iterable[Any] | None, optional
        Items to iterate over.
    desc : str, optional
        Description printed once to stderr when iteration starts.
    unit : str, optional
        Unit label, accepted for tqdm API compatibility and unused.
    total : int | None, optional
        Total item count, accepted for tqdm API compatibility and unused.
    dynamic_ncols : bool, optional
        Whether to resize dynamically, accepted for tqdm API compatibility
        and unused.
    """

    def __init__(
        self,
        iterable: Iterable[Any] | None = None,
        *,
        desc: str = "",
        unit: str = "",
        total: int | None = None,
        dynamic_ncols: bool = False,
    ) -> None:
        self._iterable: Iterable[Any] = iterable if iterable is not None else []
        if desc:
            print(f"{desc}...", file=sys.stderr)

    def __iter__(self) -> Iterator[Any]:
        return iter(self._iterable)

    def __enter__(self) -> Self:
        return self

    def __exit__(self, *_: object) -> None:
        pass

    @staticmethod
    def write(msg: str, file: IO[str] = sys.stderr) -> None:
        print(msg, file=file)


def _handle_prune_app_binaries() -> None:
    """Handle ``koopa develop prune-app-binaries``."""
    from koopa.app import prune_app_binaries

    prune_app_binaries()


def _handle_format_app_json(args: list[str]) -> None:
    """Handle ``koopa develop format-app-json``.

    Parameters
    ----------
    args : list[str]
        Raw CLI arguments for this subcommand, unused.
    """
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
    """Handle ``koopa develop push-app-build <name>...``.

    Parameters
    ----------
    args : list[str]
        App names to push binary builds for.
    """
    if not args:
        print(
            "Usage: koopa develop push-app-build <name>...",
            file=sys.stderr,
        )
        sys.exit(1)
    from koopa.alert import alert, alert_note
    from koopa.install import _binary_tarball_basename, _require_binary_prefix
    from koopa.prefix import opt_prefix
    from koopa.system import arch2, os_slug

    try:
        _require_binary_prefix()
    except RuntimeError as exc:
        print(f"Error: {exc}", file=sys.stderr)
        sys.exit(1)

    aws = shutil.which("aws")
    tar = shutil.which("tar")
    if aws is None:
        msg = "aws CLI is not installed."
        raise RuntimeError(msg)
    if tar is None:
        msg = "tar is not installed."
        raise RuntimeError(msg)
    architecture = arch2()
    os_str = os_slug()
    prefix = opt_prefix()
    profile = "acidgenomics"
    from koopa.aws import koopa_s3_bucket

    s3_bucket = f"s3://{koopa_s3_bucket('artifacts')}/binaries"
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
            tarball_name = _binary_tarball_basename(name, version)
            local_tar_dir = os.path.join(tmp_dir, name)
            os.makedirs(local_tar_dir, exist_ok=True)
            local_tar = os.path.join(local_tar_dir, tarball_name)
            s3_rel = f"/{os_str}/{architecture}/{name}/{tarball_name}"
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
            "Error: push requires KOOPA_BUILDER=1 and either (vendor push "
            "credentials) or (acidgenomics AWS profile + AWS_ACCOUNT_ID + aws CLI).",
            file=sys.stderr,
        )
        sys.exit(1)
    push_missing_app_builds()


_TAR_SUFFIX_METHOD: dict[str, str] = {
    ".tar.gz": "gzip",
    ".tgz": "gzip",
    ".tar.bz2": "bzip2",
    ".tbz2": "bzip2",
    ".tar.xz": "xz",
    ".txz": "xz",
}


def _tar_suffix(name: str) -> str | None:
    """Return the known tar compression suffix at the end of *name*, if any.

    Parameters
    ----------
    name : str
        Filename to check for a known tar compression suffix.

    Returns
    -------
    str | None
        The matching suffix (e.g. ``".tar.gz"``), or None if none matched.
    """
    lname = name.lower()
    for suffix in sorted(_TAR_SUFFIX_METHOD, key=len, reverse=True):
        if lname.endswith(suffix):
            return suffix
    return None


def _version_from_filename(app: str, path: str) -> str | None:
    """Best-effort extraction of a version string from a vendor tarball filename.

    Parameters
    ----------
    app : str
        App name, stripped as a prefix from the filename before matching.
    path : str
        Path to the vendor tarball whose filename is inspected.

    Returns
    -------
    str | None
        The extracted version string, or None if none was found.
    """
    import re

    base = os.path.basename(path)
    suffix = _tar_suffix(base)
    if suffix is not None:
        base = base[: -len(suffix)]
    stripped = re.sub(rf"^{re.escape(app)}[-_]?", "", base, flags=re.IGNORECASE)
    match = re.search(r"\d+(?:\.\d+)+", stripped)
    return match.group(0) if match else None


def _handle_push_installer(args: list[str]) -> None:
    """Handle ``koopa develop push-installer <app> <file>``.

    Stages a manually-downloaded, EULA-gated vendor installer tarball (e.g.
    cellranger, bcl-convert) to the private artifacts S3 bucket, at the key
    declared by the app's 'installer_artifact' template in app.json. Recompresses
    to the format that template requires when the input archive differs, without
    otherwise altering the tar member layout the installer expects after
    ``koopa.archive.extract()``.

    Parameters
    ----------
    args : list[str]
        Raw CLI arguments for this subcommand: the app name, the path to the
        downloaded installer tarball, and optional ``--version``/``--force``
        flags.
    """
    import argparse

    from koopa.app import installer_artifact_key
    from koopa.archive import is_valid_archive, repackage_tar
    from koopa.aws import koopa_s3_bucket, s3_object_exists
    from koopa.install import _has_private_access
    from koopa.io import import_app_json

    parser = argparse.ArgumentParser(
        prog="koopa develop push-installer",
        description="Stage a downloaded vendor installer tarball to the private artifacts bucket.",
    )
    parser.add_argument("app", help="app name (must declare 'installer_artifact' in app.json)")
    parser.add_argument("file", help="path to the downloaded installer tarball")
    parser.add_argument(
        "--version",
        default=None,
        help="version to stage (default: derived from the filename, else the app.json pin)",
    )
    parser.add_argument(
        "--force",
        action="store_true",
        help="overwrite an already-staged artifact",
    )
    parsed = parser.parse_args(args)

    if not _has_private_access():
        print(
            "Error: push-installer requires the 'acidgenomics' AWS profile and AWS_ACCOUNT_ID.",
            file=sys.stderr,
        )
        sys.exit(1)

    aws = shutil.which("aws")
    if aws is None:
        msg = "aws CLI is not installed."
        raise RuntimeError(msg)

    if not os.path.isfile(parsed.file):
        print(f"Error: file not found: {parsed.file!r}.", file=sys.stderr)
        sys.exit(1)
    if not is_valid_archive(parsed.file):
        print(f"Error: {parsed.file!r} does not look like a valid archive.", file=sys.stderr)
        sys.exit(1)

    data = import_app_json()
    if parsed.app not in data:
        print(f"Error: {parsed.app!r} not found in app.json.", file=sys.stderr)
        sys.exit(1)
    entry = data[parsed.app]
    template = entry.get("installer_artifact", "") if isinstance(entry, dict) else ""
    if not template:
        print(
            f"Error: {parsed.app!r} has no 'installer_artifact' declared in app.json.",
            file=sys.stderr,
        )
        sys.exit(1)

    version = (
        parsed.version
        or _version_from_filename(parsed.app, parsed.file)
        or entry.get("version", "")
    )
    if not version:
        print("Error: could not determine a version; pass --version explicitly.", file=sys.stderr)
        sys.exit(1)

    key = installer_artifact_key(parsed.app, version)
    if key is None:
        print(
            f"Error: {parsed.app!r} has no 'installer_artifact' declared in app.json.",
            file=sys.stderr,
        )
        sys.exit(1)
    key_suffix = _tar_suffix(key)
    if key_suffix is None:
        print(
            f"Error: {parsed.app!r}'s 'installer_artifact' template has an unsupported extension.",
            file=sys.stderr,
        )
        sys.exit(1)

    bucket = koopa_s3_bucket("artifacts")
    if not parsed.force and s3_object_exists(bucket, key):
        print(
            f"Error: 's3://{bucket}/{key}' already exists. Pass --force to overwrite.",
            file=sys.stderr,
        )
        sys.exit(1)

    tmp_dir = tempfile.mkdtemp()
    try:
        local_path = os.path.join(tmp_dir, os.path.basename(key))
        input_suffix = _tar_suffix(parsed.file)
        if input_suffix == key_suffix:
            shutil.copyfile(parsed.file, local_path)
        else:
            print(f"Recompressing '{parsed.file}' to match {key_suffix!r}.")
            repackage_tar(parsed.file, local_path, method=_TAR_SUFFIX_METHOD[key_suffix])
        remote = f"s3://{bucket}/{key}"
        print(f"Uploading '{local_path}' to '{remote}'.")
        subprocess.run(
            [aws, "s3", "cp", local_path, remote, "--profile=acidgenomics"],
            check=True,
        )
        print(f"Staged: {remote}")
    finally:
        shutil.rmtree(tmp_dir, ignore_errors=True)


def _handle_scrub_install_info(args: list[str]) -> None:
    """Handle ``koopa develop scrub-install-info [--dry-run] [<name>...]``.

    Parameters
    ----------
    args : list[str]
        Raw CLI arguments for this subcommand: app name(s) to scrub, and an
        optional ``--dry-run`` flag.
    """
    import argparse

    from koopa.alert import alert, alert_success
    from koopa.install_info import scrub_install_info
    from koopa.text import plural

    parser = argparse.ArgumentParser(
        prog="koopa develop scrub-install-info",
        description="Rewrite existing .install/info.json 'environ' blocks down to the allowlist.",
    )
    parser.add_argument(
        "names", nargs="*", help="app name(s) to scrub (default: every installed app)"
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="report what would change without writing",
    )
    parsed = parser.parse_args(args)

    scrubbed = scrub_install_info(parsed.names or None, dry_run=parsed.dry_run)
    if not scrubbed:
        alert_success("No non-allowlisted environ keys found.")
        return
    verb = "Would scrub" if parsed.dry_run else "Scrubbed"
    for info_file, removed_keys in scrubbed:
        alert(f"{verb} '{info_file}': removed {', '.join(removed_keys)}")
    if not parsed.dry_run:
        n = len(scrubbed)
        alert_success(f"Scrubbed {n} {plural(n, 'info.json file')}.")


def _collect_shell_files() -> dict[str, list[str]]:
    """Collect shell files grouped by shell type (posix, bash, zsh).

    Searches functions/ subdirectories and include/ files across all lang/
    shell prefixes. Shell type is determined by shebang line.

    Returns
    -------
    dict[str, list[str]]
        Mapping of shell type (``"posix"``, ``"bash"``, ``"zsh"``) to the
        sorted list of shell file paths for that type.
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
    """Check files for illegal string patterns. Returns list of error messages.

    Parameters
    ----------
    files : list[str]
        Paths of shell files to check.
    extra_patterns : list[tuple[str, str]]
        Additional (regex, message) pairs to check, on top of the patterns
        in ``_ILLEGAL_ALL``.

    Returns
    -------
    list[str]
        Error messages for each illegal pattern match found.
    """
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


_SKILL_DESCRIPTION_MAX_LEN = 1023


def _skill_frontmatter_errors(path: str) -> list[str]:
    """Validate one SKILL.md's frontmatter. Returns list of error messages.

    Enforces the cross-CLI compatibility contract: ``description: >-`` (folded-strip
    block scalar), never plain ``>`` or an inline scalar, and a 1023-char raw length
    budget. The 1024-char cap on the *parsed* description is a spec-level constraint
    of the open Agent Skills format (agentskills.io), not just a Copilot CLI quirk --
    Codex CLI hardcodes the same ``MAX_DESCRIPTION_LEN=1024``. Plain ``>`` folds in a
    trailing newline (parsed = raw + 1), silently spending 1 char of that budget for
    nothing; an over-cap skill gets dropped by whichever CLI reads it.

    Parameters
    ----------
    path : str
        Path to the ``SKILL.md`` file to validate.

    Returns
    -------
    list[str]
        Error messages describing any frontmatter violations found.
    """
    with open(path, errors="replace") as fh:
        lines = fh.read().split("\n")
    if not lines or lines[0].strip() != "---":
        return [f"{path}:1: missing opening '---' frontmatter delimiter"]
    end = next((i for i in range(1, len(lines)) if lines[i].strip() == "---"), None)
    if end is None:
        return [f"{path}:1: missing closing '---' frontmatter delimiter"]
    fm = lines[1:end]
    errors: list[str] = []
    if not any(line.startswith("name:") for line in fm):
        errors.append(f"{path}:1: missing 'name:' key in frontmatter")
    desc_idx = next((i for i, line in enumerate(fm) if line.startswith("description:")), None)
    if desc_idx is None:
        errors.append(f"{path}:1: missing 'description:' key in frontmatter")
        return errors
    lineno = desc_idx + 2  # +1 for 0-index, +1 for the opening '---' line
    style = fm[desc_idx].split(":", 1)[1].strip()
    if style != ">-":
        errors.append(
            f"{path}:{lineno}: description must use 'description: >-' "
            f"(found {style!r}); anything else risks a parsed-length mismatch "
            "against the Agent Skills spec's 1024-char cap"
        )
        errors.append(f"  {fm[desc_idx].rstrip()}")
    body: list[str] = []
    for line in fm[desc_idx + 1 :]:
        if line.strip() == "" or line.startswith(" "):
            body.append(line.strip())
        else:
            break
    raw = " ".join(part for part in body if part) if style in (">-", ">", "|", "|-") else style
    if len(raw) > _SKILL_DESCRIPTION_MAX_LEN:
        errors.append(
            f"{path}:{lineno}: description is {len(raw)} chars, over the "
            f"{_SKILL_DESCRIPTION_MAX_LEN}-char budget (the Agent Skills spec caps "
            "the parsed description at 1024 chars; over-cap skills get dropped)"
        )
    return errors


def _handle_check_skills(args: list[str]) -> None:
    """Handle ``koopa develop check-skills [path...]``.

    Validates every ``SKILL.md``'s frontmatter for cross-CLI compatibility. See
    ``_skill_frontmatter_errors`` for the exact rules enforced.

    Parameters
    ----------
    args : list[str]
        Raw CLI arguments for this subcommand: optional skill-directory
        root paths to check.
    """
    import argparse
    import glob

    from koopa.alert import alert, alert_success
    from koopa.prefix import koopa_prefix

    parser = argparse.ArgumentParser(
        prog="koopa develop check-skills",
        description="Validate SKILL.md frontmatter for cross-CLI compatibility.",
    )
    parser.add_argument(
        "roots",
        nargs="*",
        metavar="PATH",
        help=(
            "skill-directory roots to check (default: <prefix>/.claude/skills, "
            "<prefix>/opt/dotfiles/chezmoi/dot_claude/skills, and any "
            "<prefix>/plugins/*/skills)"
        ),
    )
    parsed = parser.parse_args(args)

    if parsed.roots:
        roots = [os.path.expanduser(root) for root in parsed.roots]
    else:
        prefix = koopa_prefix()
        roots = [
            os.path.join(prefix, ".claude", "skills"),
            os.path.join(prefix, "opt", "dotfiles", "chezmoi", "dot_claude", "skills"),
            *sorted(glob.glob(os.path.join(prefix, "plugins", "*", "skills"))),
        ]

    skill_files: list[str] = []
    for root in roots:
        if not os.path.isdir(root):
            continue
        for name in sorted(os.listdir(root)):
            skill_md = os.path.join(root, name, "SKILL.md")
            if os.path.isfile(skill_md):
                skill_files.append(skill_md)

    if not skill_files:
        print("Error: no SKILL.md files found under the given roots.", file=sys.stderr)
        sys.exit(1)

    alert(f"Checking frontmatter on {len(skill_files)} skills.")
    errors: list[str] = []
    for path in skill_files:
        errors += _skill_frontmatter_errors(path)

    if errors:
        for line in errors:
            print(line, file=sys.stderr)
        sys.exit(1)
    alert_success(f"check-skills passed [{len(skill_files)} skills].")


def _handle_check_app_versions(args: list[str]) -> None:
    """Handle ``koopa develop check-app-versions``.

    Parameters
    ----------
    args : list[str]
        Raw CLI arguments for this subcommand: optional app names to check,
        and flags such as ``--json``, ``--source``, ``--no-update``,
        ``--s3-upload``, and ``--reset-cache``.
    """
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
        "--no-update",
        action="store_true",
        dest="no_update",
        help="skip updating app.json with latest versions",
    )
    parser.add_argument(
        "--s3-upload",
        action="store_true",
        dest="s3_upload",
        help=(
            "upload source tarballs to the private koopa S3 bucket"
            " (requires acidgenomics AWS profile)"
        ),
    )
    parser.add_argument(
        "--reset-cache",
        action="store_true",
        help="clear version cache and force fresh lookups",
    )
    parsed = parser.parse_args(args)
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
                f"Install in progress (PID {pid}). "
                "Wait for it to finish or remove "
                f"'{lock_path}' if the process is stale."
            )
            sys.exit(1)
        except PermissionError:
            alert_note(
                f"Install in progress (PID {pid}). "
                "Wait for it to finish or remove "
                f"'{lock_path}' if the process is stale."
            )
            sys.exit(1)
        except (ValueError, ProcessLookupError, OSError) as exc:
            alert_note(f"Ignoring stale/unreadable install lock '{lock_path}': {exc}")
    results = check_app_versions(
        source_filter=parsed.source,
        name_filter=parsed.apps or None,
        reset_cache=parsed.reset_cache,
    )
    if parsed.output_json:
        print_json_report(results)
    else:
        print_report(results)
    if not parsed.no_update:
        update_app_json(results, s3_upload=parsed.s3_upload)


def _run_pytest(args: list[str]) -> int:
    """Run ``pytest`` over the koopa test suite.

    Parameters
    ----------
    args : list[str]
        Extra arguments passed through to the ``pytest`` invocation.

    Returns
    -------
    int
        Exit code returned by ``pytest``.
    """
    from koopa.prefix import python_prefix

    py_prefix = python_prefix()
    tests_dir = os.path.join(py_prefix, "tests")
    src_dir = os.path.join(py_prefix, "src")
    pytest_cmd = shutil.which("pytest")
    if pytest_cmd is None:
        msg = "pytest is not installed."
        raise RuntimeError(msg)
    env = os.environ.copy()
    existing = env.get("PYTHONPATH", "")
    env["PYTHONPATH"] = f"{src_dir}:{existing}" if existing else src_dir
    return subprocess.run([pytest_cmd, tests_dir, *args], env=env, check=False).returncode


def _handle_pytest(args: list[str]) -> None:
    """Handle ``koopa develop pytest``.

    Parameters
    ----------
    args : list[str]
        Extra arguments passed through to the ``pytest`` invocation.
    """
    sys.exit(_run_pytest(args))


def _run_pyright(args: list[str]) -> int:
    """Run ``pyright`` over the koopa source tree.

    Parameters
    ----------
    args : list[str]
        Extra arguments passed through to the ``pyright`` invocation.

    Returns
    -------
    int
        Exit code returned by ``pyright``.
    """
    from koopa.prefix import python_prefix

    src_dir = os.path.join(python_prefix(), "src", "koopa")
    pyright_cmd = shutil.which("pyright")
    if pyright_cmd is None:
        msg = "pyright is not installed."
        raise RuntimeError(msg)
    return subprocess.run([pyright_cmd, src_dir, *args], check=False).returncode


def _handle_pyright(args: list[str]) -> None:
    """Handle ``koopa develop pyright``.

    Parameters
    ----------
    args : list[str]
        Extra arguments passed through to the ``pyright`` invocation.
    """
    sys.exit(_run_pyright(args))


def _run_ty(args: list[str]) -> int:
    """Run ``ty check`` over the koopa source tree.

    Passes ``--project`` explicitly, since ``ty`` resolves ``pyproject.toml``
    from the project directory rather than from the target path -- unlike
    ``ruff`` and ``numpydoc``, which both walk up from the target path itself.
    Without it, ``[tool.ty]`` (its ``extra-paths`` in particular) is silently
    ignored when the caller's working directory is outside the koopa checkout.

    Parameters
    ----------
    args : list[str]
        Extra arguments passed through to the ``ty check`` invocation.

    Returns
    -------
    int
        Exit code returned by ``ty check``.
    """
    from koopa.prefix import koopa_prefix, python_prefix

    src_dir = os.path.join(python_prefix(), "src", "koopa")
    ty_cmd = shutil.which("ty")
    if ty_cmd is None:
        msg = "ty is not installed."
        raise RuntimeError(msg)
    cmd = [ty_cmd, "check", "--project", koopa_prefix(), src_dir, *args]
    return subprocess.run(cmd, check=False).returncode


def _handle_ty(args: list[str]) -> None:
    """Handle ``koopa develop ty``.

    Parameters
    ----------
    args : list[str]
        Extra arguments passed through to the ``ty check`` invocation.
    """
    sys.exit(_run_ty(args))


def _run_numpydoc(args: list[str]) -> int:
    """Run ``numpydoc lint`` over the koopa source tree.

    Parameters
    ----------
    args : list[str]
        Extra arguments passed through to the ``numpydoc lint`` invocation.

    Returns
    -------
    int
        Exit code returned by ``numpydoc lint``.
    """
    from pathlib import Path

    from koopa.prefix import python_prefix

    src_dir = os.path.join(python_prefix(), "src", "koopa")
    numpydoc_cmd = shutil.which("numpydoc")
    if numpydoc_cmd is None:
        msg = "numpydoc is not installed."
        raise RuntimeError(msg)
    files = sorted(str(p) for p in Path(src_dir).rglob("*.py"))
    return subprocess.run([numpydoc_cmd, "lint", *files, *args], check=False).returncode


def _handle_numpydoc(args: list[str]) -> None:
    """Handle ``koopa develop numpydoc``.

    Parameters
    ----------
    args : list[str]
        Extra arguments passed through to the ``numpydoc lint`` invocation.
    """
    sys.exit(_run_numpydoc(args))


def _run_ruff_check(args: list[str]) -> int:
    """Run ``ruff check`` over the koopa source tree.

    Parameters
    ----------
    args : list[str]
        Extra arguments passed through to the ``ruff check`` invocation.

    Returns
    -------
    int
        Exit code returned by ``ruff check``.
    """
    from koopa.prefix import python_prefix

    src_dir = os.path.join(python_prefix(), "src", "koopa")
    ruff_cmd = shutil.which("ruff")
    if ruff_cmd is None:
        msg = "ruff is not installed."
        raise RuntimeError(msg)
    return subprocess.run([ruff_cmd, "check", src_dir, *args], check=False).returncode


def _run_ruff_format_check(args: list[str]) -> int:
    """Run ``ruff format --check`` over the koopa source tree.

    Parameters
    ----------
    args : list[str]
        Extra arguments passed through to the ``ruff format --check``
        invocation.

    Returns
    -------
    int
        Exit code returned by ``ruff format --check``.
    """
    from koopa.prefix import python_prefix

    src_dir = os.path.join(python_prefix(), "src", "koopa")
    ruff_cmd = shutil.which("ruff")
    if ruff_cmd is None:
        msg = "ruff is not installed."
        raise RuntimeError(msg)
    cmd = [ruff_cmd, "format", "--check", src_dir, *args]
    return subprocess.run(cmd, check=False).returncode


def _handle_check(args: list[str]) -> None:
    """Handle ``koopa develop check``.

    Runs the full Python quality gate as one command: ``ruff check``,
    ``ruff format --check``, ``pyright``, ``ty check``, ``numpydoc``, then
    ``pytest``. Every phase runs even after an earlier one fails, so a single
    invocation surfaces every problem instead of stopping at the first.

    Parameters
    ----------
    args : list[str]
        Raw CLI arguments for this subcommand. Rejected if non-empty, since
        an argument cannot be routed unambiguously across six tools.
    """
    from koopa.alert import alert, alert_success, warn

    if args:
        msg = (
            "'koopa develop check' takes no arguments. Run the individual "
            "subcommands instead: ruff-check, ruff-format-check, pyright, "
            "ty, numpydoc, pytest."
        )
        raise RuntimeError(msg)
    phases: list[tuple[str, Callable[[list[str]], int]]] = [
        ("ruff check", _run_ruff_check),
        ("ruff format", _run_ruff_format_check),
        ("pyright", _run_pyright),
        ("ty check", _run_ty),
        ("numpydoc", _run_numpydoc),
        ("pytest", _run_pytest),
    ]
    failed: list[str] = []
    for label, runner in phases:
        alert(f"Running {label}.")
        if runner([]) == 0:
            alert_success(f"{label} passed.")
        else:
            warn(f"{label} failed.")
            failed.append(label)
    if failed:
        msg = f"{len(failed)} of {len(phases)} checks failed: {', '.join(failed)}."
        raise RuntimeError(msg)
    alert_success("All checks passed.")


def _handle_generate_completion() -> None:
    """Handle ``koopa develop generate-completion``."""
    from koopa.alert import alert_note, alert_success
    from koopa.generate_completion import generate_completion

    generate_completion()
    alert_success("Completion file updated.")
    alert_note("Reload your shell to apply changes.")


def _list_s3_keys(aws: str, bucket: str, prefix: str, profile: str) -> set[str]:
    """List all object keys in bucket under prefix via paginated list-objects-v2.

    Parameters
    ----------
    aws : str
        Path to the ``aws`` CLI executable.
    bucket : str
        S3 bucket name to list.
    prefix : str
        Key prefix to filter listed objects by.
    profile : str
        AWS CLI profile name to use.

    Returns
    -------
    set[str]
        All object keys found under the given prefix.
    """
    import json as _json

    keys: set[str] = set()
    token = None
    while True:
        cmd = [
            aws,
            "s3api",
            "list-objects-v2",
            "--bucket",
            bucket,
            "--prefix",
            prefix,
            "--profile",
            profile,
            "--output",
            "json",
        ]
        if token:
            cmd += ["--continuation-token", token]
        result = subprocess.run(cmd, capture_output=True, text=True, check=False)
        if result.returncode != 0:
            break
        resp = _json.loads(result.stdout)
        for obj in resp.get("Contents", []):
            keys.add(obj["Key"])
        token = resp.get("NextContinuationToken")
        if not token:
            break
    return keys


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


def _handle_mirror_src(args: list[str]) -> None:  # noqa: C901, PLR0912, PLR0915
    """Handle ``koopa develop mirror-src [<name>...]``.

    Downloads source tarballs from upstream and uploads to the
    private koopa S3 src/ mirror. With no args, mirrors all
    apps with a ``"src_url"`` defined in app.json.

    Parameters
    ----------
    args : list[str]
        Raw CLI arguments for this subcommand: optional app names to
        mirror, and an optional ``--prune`` flag.
    """
    import time

    from koopa.download import _derive_filename
    from koopa.io import import_app_json
    from koopa.text import plural
    from koopa.vendor import vendor_can_push
    from koopa.vendor import vendor_config as _vendor_config
    from koopa.version_check import _expand_src_url, _has_acidgenomics_aws, _mirror_src_to_s3

    if "--help" in args or "-h" in args:
        print(
            "usage: koopa develop mirror-src [--prune] [<name>...]\n\n"
            "Download source tarballs from upstream and upload to the\n"
            "private koopa S3 src/ mirror and/or vendor backend.\n\n"
            "With no args, mirrors all apps with a 'src_url' in app.json.\n\n"
            "Options:\n"
            "  --prune  Delete stale files from S3 after mirroring",
            file=sys.stderr,
        )
        return
    prune = "--prune" in args
    args = [a for a in args if a != "--prune"]
    _has_vendor = _vendor_config() is not None and vendor_can_push()
    if not _has_acidgenomics_aws() and not _has_vendor:
        print(
            "Error: no upload destination available. "
            "Configure the 'acidgenomics' AWS profile or a vendor backend.",
            file=sys.stderr,
        )
        sys.exit(1)
    aws = shutil.which("aws")
    if aws is None and not _has_vendor:
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
        targets = sorted(k for k, v in data.items() if v.get("src_url") and not v.get("removed"))
        if not targets:
            print("Error: No apps with 'src_url' found in app.json.", file=sys.stderr)
            sys.exit(1)
    try:
        from tqdm import tqdm  # pyright: ignore[reportMissingModuleSource]
    except ModuleNotFoundError:
        tqdm = cast(Any, _TqdmFallback)  # type: ignore[assignment]

    from koopa.aws import koopa_s3_bucket

    bucket = koopa_s3_bucket("koopa")
    cache = _load_mirror_src_cache()
    now = time.time()
    _cache_ttl = 86400  # 24 hours
    failures: dict[str, str] = {}
    existing_keys: set[str] = set()
    if aws is not None and _has_acidgenomics_aws():
        print("Listing S3 objects...", file=sys.stderr)
        existing_keys = _list_s3_keys(aws, bucket, "src/", "acidgenomics")

    def _mirror_one(name: str) -> None:
        entry = data[name]
        version = entry.get("version", "")
        src_url = entry.get("src_url", "")
        if not version or not src_url:
            return
        url = _expand_src_url(src_url, version)
        filename = _derive_filename(url)
        cache_key = f"{name}/{filename}"
        if cache_key in cache and (now - cache[cache_key]) < _cache_ttl:
            return
        key = f"src/{cache_key}"
        if key in existing_keys:
            cache[cache_key] = now
            return
        try:
            tqdm.write(f"  Mirroring: {cache_key}")
            _mirror_src_to_s3(name, version, src_url, strict=True, quiet=True)
            tqdm.write(f"  Mirrored: {cache_key}")
            cache[cache_key] = now
        except Exception as exc:
            failures[name] = str(exc)
            tqdm.write(f"  FAILED: {name}: {exc}")
            return
        for extra_tmpl in entry.get("extra_src_urls", []):
            extra_url = _expand_src_url(extra_tmpl, version)
            extra_filename = _derive_filename(extra_url)
            extra_cache_key = f"{name}/{extra_filename}"
            if extra_cache_key in cache and (now - cache[extra_cache_key]) < _cache_ttl:
                continue
            extra_key = f"src/{extra_cache_key}"
            if extra_key in existing_keys:
                cache[extra_cache_key] = now
                continue
            try:
                tqdm.write(f"  Mirroring: {extra_cache_key}")
                _mirror_src_to_s3(name, version, extra_tmpl, strict=True, quiet=True)
                tqdm.write(f"  Mirrored: {extra_cache_key}")
                cache[extra_cache_key] = now
            except Exception as exc:
                failures[name] = str(exc)
                tqdm.write(f"  FAILED (extra): {name}/{extra_filename}: {exc}")

    for name in tqdm(targets, desc="Mirroring", unit="app", dynamic_ncols=True):
        _mirror_one(name)
    _save_mirror_src_cache(cache)

    if not prune:
        if failures:
            n = len(failures)
            print(
                f"\n{n} {plural(n, 'app')} failed to mirror:",
                file=sys.stderr,
            )
            for fname, reason in sorted(failures.items()):
                print(f"  {fname}: {reason}", file=sys.stderr)
            sys.exit(1)
        return
    removed_apps = sorted(k for k, v in data.items() if v.get("src_url") and v.get("removed"))
    stale_keys: list[str] = []
    for name in targets:
        entry = data[name]
        version = entry.get("version", "")
        src_url = entry.get("src_url", "")
        if not version or not src_url:
            continue
        expected: set[str] = set()
        url = _expand_src_url(src_url, version)
        expected.add(_derive_filename(url))
        for extra_tmpl in entry.get("extra_src_urls", []):
            extra_url = _expand_src_url(extra_tmpl, version)
            expected.add(_derive_filename(extra_url))
        prefix = f"src/{name}/"
        for key in existing_keys:
            if not key.startswith(prefix):
                continue
            filename = key.rsplit("/", 1)[-1]
            if filename not in expected:
                stale_keys.append(key)
    for name in removed_apps:
        prefix = f"src/{name}/"
        for key in existing_keys:
            if key.startswith(prefix):
                stale_keys.append(key)
    if stale_keys:
        from koopa.aws import _aws

        n = len(stale_keys)
        print(f"Pruning {n} stale {plural(n, 'file')}...", file=sys.stderr)
        for key in stale_keys:
            print(f"  s3://{bucket}/{key}", file=sys.stderr)
        for key in stale_keys:
            uri = f"s3://{bucket}/{key}"
            for attempt in range(3):
                try:
                    _aws("s3", "rm", uri, "--profile", "acidgenomics")
                    print(f"  Deleted: {key}", file=sys.stderr)
                    break
                except subprocess.CalledProcessError as exc:
                    if attempt < 2:
                        time.sleep(2)
                        continue
                    print(f"  FAILED: {key}: {exc.stderr.strip()}", file=sys.stderr)
                except subprocess.TimeoutExpired:
                    if attempt < 2:
                        time.sleep(2)
                        continue
                    print(f"  TIMEOUT: {key}", file=sys.stderr)

    if failures:
        n = len(failures)
        print(
            f"\n{n} {plural(n, 'app')} failed to mirror:",
            file=sys.stderr,
        )
        for fname, reason in sorted(failures.items()):
            print(f"  {fname}: {reason}", file=sys.stderr)
        sys.exit(1)


def _handle_audit_src_mirror(args: list[str]) -> None:
    """Handle ``koopa develop audit-src-mirror [<name>...]``.

    Checks which mirror apps have their current source tarball present in
    the private koopa S3 src/ mirror using a lightweight head-object call.
    Exits 1 if any are missing.

    Parameters
    ----------
    args : list[str]
        Raw CLI arguments for this subcommand: optional app names to audit
        (default: every app with a ``"src_url"`` in app.json).
    """
    import shutil as _shutil

    from koopa.download import _derive_filename
    from koopa.io import import_app_json
    from koopa.text import plural
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
        targets = sorted(k for k, v in data.items() if v.get("src_url") and not v.get("removed"))
        if not targets:
            print("Error: No apps with 'src_url' found in app.json.", file=sys.stderr)
            sys.exit(1)
    try:
        from tqdm import tqdm  # pyright: ignore[reportMissingModuleSource]
    except ModuleNotFoundError:
        tqdm = cast(Any, _TqdmFallback)  # type: ignore[assignment]

    from koopa.aws import koopa_s3_bucket

    bucket = koopa_s3_bucket("koopa")
    missing: list[str] = []
    for name in tqdm(targets, desc="Auditing", unit="app", dynamic_ncols=True):
        entry = data[name]
        version = entry.get("version", "")
        src_url = entry.get("src_url", "")
        if not version or not src_url:
            continue
        url = _expand_src_url(src_url, version)
        filename = _derive_filename(url)
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
        if result.returncode != 0:
            tqdm.write(f"  MISS  {name}/{filename}")
            missing.append(name)
        for extra_tmpl in entry.get("extra_src_urls", []):
            extra_url = _expand_src_url(extra_tmpl, version)
            extra_filename = _derive_filename(extra_url)
            extra_key = f"src/{name}/{extra_filename}"
            extra_result = subprocess.run(
                [
                    aws,
                    "s3api",
                    "head-object",
                    "--bucket",
                    bucket,
                    "--key",
                    extra_key,
                    "--profile",
                    "acidgenomics",
                ],
                capture_output=True,
                check=False,
            )
            if extra_result.returncode != 0:
                tqdm.write(f"  MISS  {name}/{extra_filename}")
                if name not in missing:
                    missing.append(name)
    if missing:
        n = len(missing)
        print(
            f"\n{n} {plural(n, 'app')} missing from mirror: {', '.join(missing)}",
            file=sys.stderr,
        )
        sys.exit(1)
    else:
        n = len(targets)
        print(f"\nAll {n} {plural(n, 'app')} present in mirror.")


def _handle_remove_app(args: list[str]) -> None:
    """Handle ``koopa develop remove-app <name> [--revdeps <app>...]``.

    Tombstones *name* in app.json, increments the ``revision`` counter on all
    reverse dependencies so that ``koopa update`` will automatically rebuild
    them, and deletes the installer file if one exists.

    Run this command BEFORE editing installer files or removing the dep from
    app.json dependency lists so that auto-detection of reverse dependencies
    still works.

    Parameters
    ----------
    args : list[str]
        Raw CLI arguments for this subcommand: the app name to remove, and
        an optional ``--revdeps <app>...`` override list.
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

    Parameters
    ----------
    args : list[str]
        App names to bump the revision counter for.
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


def _handle_reset_revisions() -> None:
    """Handle ``koopa develop reset-revisions``.

    Removes the ``revision`` key from all apps in app.json.
    """
    from koopa.io import export_app_json, import_app_json

    data = import_app_json()
    reset = []
    for app in sorted(data):
        if "revision" in data[app]:
            del data[app]["revision"]
            reset.append(app)
    if not reset:
        print("No revisions to remove.")
        return
    for app in reset:
        print(f"  {app}: revision removed")
    export_app_json(data)


def _handle_bump_venv_version(_: list[str]) -> None:
    """Handle ``koopa develop bump-venv-version``.

    Stamps a new venv version in etc/koopa/venv-version.txt.
    This marks the .venv as stale so ``koopa update`` will reinstall it.

    Parameters
    ----------
    _ : list[str]
        Raw CLI arguments for this subcommand, unused.
    """
    import time

    from koopa.prefix import koopa_prefix

    version_file = os.path.join(koopa_prefix(), "etc", "koopa", "venv-version.txt")
    current = ""
    if os.path.isfile(version_file):
        with open(version_file) as f:
            current = f.read().strip()
    new = time.strftime("%Y.%m.%d.%H%M")
    with open(version_file, "w") as f:
        f.write(f"{new}\n")
    print(f"  venv-version: {current} -> {new}")


def _handle_bump_bootstrap(_: list[str]) -> None:
    """Handle ``koopa develop bump-bootstrap``.

    Stamps a new bootstrap version in etc/koopa/bootstrap-version.txt.
    This marks existing bootstraps as stale so ``koopa update`` will rebuild.

    Parameters
    ----------
    _ : list[str]
        Raw CLI arguments for this subcommand, unused.
    """
    import time

    from koopa.prefix import koopa_prefix

    version_file = os.path.join(koopa_prefix(), "etc", "koopa", "bootstrap-version.txt")
    current = ""
    if os.path.isfile(version_file):
        with open(version_file) as f:
            current = f.read().strip()
    new = time.strftime("%Y.%m.%d.%H%M")
    with open(version_file, "w") as f:
        f.write(f"{new}\n")
    print(f"  bootstrap-version: {current} -> {new}")


def _handle_app_deps(args: list[str]) -> None:
    """Handle ``koopa develop app-deps <name>``.

    Parameters
    ----------
    args : list[str]
        Raw CLI arguments for this subcommand: the app name to list
        dependencies for.
    """
    from koopa.app import app_deps

    if not args:
        print("Usage: koopa develop app-deps <name>", file=sys.stderr)
        sys.exit(1)
    name = args[0]
    try:
        deps = app_deps(name)
    except NameError as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)
    if not deps:
        print(f"{name} has no dependencies.")
        return
    print(f"{name} ({len(deps)} dependencies):")
    for dep in deps:
        print(f"  {dep}")


def _handle_app_revdeps(args: list[str]) -> None:
    """Handle ``koopa develop app-revdeps <name>``.

    Parameters
    ----------
    args : list[str]
        Raw CLI arguments for this subcommand: the app name to list reverse
        dependencies for, and an optional ``--all`` flag.
    """
    from koopa.app import app_revdeps

    if not args:
        print("Usage: koopa develop app-revdeps <name>", file=sys.stderr)
        sys.exit(1)
    name = args[0]
    mode = "all" if "--all" in args else "default"
    try:
        revdeps = app_revdeps(name, mode=mode)
    except NameError as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)
    if not revdeps:
        print(f"No apps depend on {name}.")
        return
    print(f"{name} is depended on by ({len(revdeps)} apps):")
    for dep in revdeps:
        print(f"  {dep}")


def _handle_circular_dependencies() -> None:
    """Handle ``koopa develop circular-dependencies``."""
    from koopa.check import check_circular_deps
    from koopa.text import plural

    cycles = check_circular_deps()
    if not cycles:
        print("No circular dependencies detected.")
        return
    n = len(cycles)
    print(f"Found {n} {plural(n, 'circular dependency chain')}:")
    for cycle in cycles:
        print(f"  {' -> '.join(cycle)}")
    sys.exit(1)


def _handle_generate_man(args: list[str]) -> None:
    """Handle ``koopa develop generate-man``.

    Parameters
    ----------
    args : list[str]
        Raw CLI arguments for this subcommand, unused.
    """
    from koopa.generate_man import write_man

    write_man()


def _handle_generate_docs(_: list[str]) -> None:
    """Handle ``koopa develop generate-docs``.

    Parameters
    ----------
    _ : list[str]
        Raw CLI arguments for this subcommand, unused.
    """
    from koopa.generate_docs import generate_docs

    generate_docs()


def _handle_update_docs(_: list[str]) -> None:
    """Handle ``koopa develop update-docs``.

    Parameters
    ----------
    _ : list[str]
        Raw CLI arguments for this subcommand, unused.
    """
    from koopa.alert import alert_success
    from koopa.update_docs import update_docs

    update_docs()
    alert_success("Documentation updated.")


def _handle_find_ignored_bin_files(_: list[str]) -> None:
    """Handle ``koopa develop find-ignored-bin-files``.

    Parameters
    ----------
    _ : list[str]
        Raw CLI arguments for this subcommand, unused.
    """
    from koopa.prefix import koopa_prefix

    prefix = koopa_prefix()
    bin_dir = os.path.join(prefix, "bin")
    candidates = [
        os.path.join(bin_dir, name)
        for name in sorted(os.listdir(bin_dir))
        if not os.path.islink(os.path.join(bin_dir, name))
    ]
    if not candidates:
        return
    result = subprocess.run(
        ["git", "check-ignore", "--stdin"],
        input="\n".join(candidates),
        capture_output=True,
        text=True,
        cwd=prefix,
        check=False,
    )
    for path in result.stdout.splitlines():
        print(path)


def _handle_orphan_apps(args: list[str]) -> None:
    """Handle ``koopa develop orphan-apps``.

    Finds apps in app.json that no other app depends on.
    By default only shows non-default library/build-tool orphans.
    Use --all to show all orphans including leaf user tools.

    Parameters
    ----------
    args : list[str]
        Raw CLI arguments for this subcommand: an optional ``--all`` flag.
    """
    from koopa.io import import_app_json
    from koopa.text import plural

    show_all = "--all" in args
    data = import_app_json()
    all_apps = set(data.keys())
    depended_on: set[str] = set()
    for app_data in data.values():
        deps = app_data.get("dependencies", [])
        if isinstance(deps, list):
            depended_on.update(deps)
        elif isinstance(deps, dict):
            for variant_deps in deps.values():
                if isinstance(variant_deps, list):
                    depended_on.update(variant_deps)
        build_deps = app_data.get("build_dependencies", [])
        if isinstance(build_deps, list):
            depended_on.update(build_deps)
        elif isinstance(build_deps, dict):
            for variant_deps in build_deps.values():
                if isinstance(variant_deps, list):
                    depended_on.update(variant_deps)
    orphans = sorted(all_apps - depended_on)
    orphans = [name for name in orphans if not data[name].get("removed", False)]
    if not show_all:
        orphans = [
            name
            for name in orphans
            if not data[name].get("default", False) and data[name].get("type") == "library"
        ]
    if not orphans:
        print("No orphan apps detected.")
        return
    n = len(orphans)
    print(f"Found {n} orphan {plural(n, 'app')}:")
    for name in orphans:
        app_type = data[name].get("type", "unknown")
        print(f"  {name} ({app_type})")


def _handle_conda_candidates(args: list[str]) -> None:
    """Handle ``koopa develop conda-candidates``.

    Finds apps that build from source but are available on conda-forge or bioconda.
    Use --verify to query conda channels and show available versions.

    Parameters
    ----------
    args : list[str]
        Raw CLI arguments for this subcommand: an optional ``--verify`` flag.
    """
    import json as json_mod
    import urllib.request

    from koopa.io import import_app_json
    from koopa.text import plural

    verify = "--verify" in args
    data = import_app_json()
    candidates = []
    for name, entry in sorted(data.items()):
        if entry.get("removed", False):
            continue
        if entry.get("installer") == "conda-package":
            continue
        if not entry.get("src_url"):
            continue
        if entry.get("type") != "cli":
            continue
        if name.startswith(("python3.", "r-")) or name in ("python", "r"):
            continue
        candidates.append(name)
    if not verify:
        print(f"Source-built apps that could potentially use conda ({len(candidates)} total):")
        for name in candidates:
            entry = data[name]
            print(f"  {name} ({entry.get('version', '?')})")
        print("\nUse --verify to check actual conda availability.")
        return
    channels = ["conda-forge", "bioconda"]
    found = []
    for name in candidates:
        entry = data[name]
        current_ver = entry.get("version", "")
        for channel in channels:
            url = f"https://api.anaconda.org/package/{channel}/{name}"
            try:
                with urllib.request.urlopen(url, timeout=10) as resp:
                    pkg_data = json_mod.loads(resp.read())
                    conda_ver = pkg_data.get("latest_version", "?")
                    found.append((name, channel, current_ver, conda_ver))
                    break
            except Exception:
                continue
    if not found:
        print("No conda candidates found.")
        return
    n = len(found)
    print(f"Found {n} source-built {plural(n, 'app')} available on conda:")
    for name, channel, current, conda in found:
        print(f"  {name}: {current} -> {conda} ({channel})")


def _handle_activation_speed_test(args: list[str]) -> None:
    """Handle ``koopa develop activation-speed-test``.

    Measures shell activation time for all supported shells and reports
    whether each shell meets its threshold. Exits non-zero if any shell
    exceeds its threshold.

    Parameters
    ----------
    args : list[str]
        Raw CLI arguments for this subcommand: ``--runs``, ``--shells``,
        ``--threshold-bash``, ``--threshold-fish``, ``--threshold-zsh``,
        and ``--verbose``.
    """
    import argparse
    import statistics
    import time

    from koopa.alert import alert, alert_success
    from koopa.prefix import koopa_prefix

    parser = argparse.ArgumentParser(
        prog="koopa develop activation-speed-test",
        description="Measure shell activation time and enforce speed thresholds.",
    )
    parser.add_argument(
        "--runs",
        type=int,
        default=10,
        metavar="N",
        help="number of timed runs per shell (default: 10)",
    )
    parser.add_argument(
        "--shells",
        nargs="+",
        default=["bash", "zsh", "fish"],
        metavar="SHELL",
        help="shells to test (default: bash zsh fish)",
    )
    parser.add_argument(
        "--threshold-bash",
        type=int,
        default=150,
        metavar="MS",
        help="fail if bash mean exceeds this ms (default: 150)",
    )
    parser.add_argument(
        "--threshold-fish",
        type=int,
        default=200,
        metavar="MS",
        help="fail if fish mean exceeds this ms (default: 200)",
    )
    parser.add_argument(
        "--threshold-zsh",
        type=int,
        default=400,
        metavar="MS",
        help="fail if zsh mean exceeds this ms (default: 400)",
    )
    parser.add_argument(
        "--verbose",
        action="store_true",
        help="print every run time, not just the summary",
    )
    parsed = parser.parse_args(args)

    thresholds: dict[str, int] = {
        "bash": parsed.threshold_bash,
        "fish": parsed.threshold_fish,
        "zsh": parsed.threshold_zsh,
    }
    prefix = koopa_prefix()
    failures: list[str] = []

    for shell in parsed.shells:
        shell_bin = shutil.which(shell)
        if shell_bin is None:
            print(f"  {shell}: not found, skipping.")
            continue
        alert(f"Timing {shell} activation ({parsed.runs} runs).")
        times_ms: list[float] = []
        # Determine the activation flag — bash needs --login, zsh does not.
        if shell == "bash":
            cmd = [shell_bin, "--login", "-i", "-c", "exit"]
        else:
            cmd = [shell_bin, "-i", "-c", "exit"]
        for _ in range(parsed.runs):
            t0 = time.monotonic()
            subprocess.run(
                cmd,
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
                check=False,
            )
            elapsed_ms = (time.monotonic() - t0) * 1000
            times_ms.append(elapsed_ms)
            if parsed.verbose:
                print(f"    {elapsed_ms:.0f}ms")
        # Drop the slowest outlier (first run is often cold-cache).
        times_sorted = sorted(times_ms)
        trimmed = times_sorted[1:] if len(times_sorted) > 2 else times_sorted
        mean_ms = statistics.mean(trimmed)
        median_ms = statistics.median(trimmed)
        min_ms = min(trimmed)
        max_ms = max(trimmed)
        threshold = thresholds.get(shell)
        status = ""
        if threshold is not None:
            if mean_ms > threshold:
                status = f"  FAIL (threshold: {threshold}ms)"
                failures.append(f"{shell}: mean {mean_ms:.0f}ms exceeds threshold {threshold}ms")
            else:
                status = f"  PASS (threshold: {threshold}ms)"
        print(
            f"  {shell}: "
            f"mean={mean_ms:.0f}ms  "
            f"median={median_ms:.0f}ms  "
            f"min={min_ms:.0f}ms  "
            f"max={max_ms:.0f}ms"
            f"{status}"
        )
        # Emit the koopa prefix so the user knows which installation was timed.
        print(f"    prefix: {prefix}")

    if failures:
        print("\nActivation speed regressions detected:", file=sys.stderr)
        for msg in failures:
            print(f"  {msg}", file=sys.stderr)
        sys.exit(1)
    alert_success("All shells meet their activation speed thresholds.")


def _handle_activation_fork_audit(args: list[str]) -> None:
    """Handle ``koopa develop activation-fork-audit``.

    Counts subprocess forks (``$(...)``) in the shell activation path and
    compares against thresholds. Exits non-zero if any threshold is exceeded.
    This is a static analysis check — no shell is spawned.

    Parameters
    ----------
    args : list[str]
        Raw CLI arguments for this subcommand: ``--threshold-bash``,
        ``--threshold-zsh``, and ``--verbose``.
    """
    import argparse
    import re

    from koopa.alert import alert, alert_success
    from koopa.prefix import koopa_prefix

    parser = argparse.ArgumentParser(
        prog="koopa develop activation-fork-audit",
        description=(
            "Count $(...) subprocess forks in activation-path shell files and enforce upper bounds."
        ),
    )
    parser.add_argument(
        "--threshold-bash",
        type=int,
        default=43,
        metavar="N",
        help="fail if bash fork count exceeds this (default: 43)",
    )
    parser.add_argument(
        "--threshold-zsh",
        type=int,
        default=39,
        metavar="N",
        help="fail if zsh fork count exceeds this (default: 39)",
    )
    parser.add_argument(
        "--verbose",
        action="store_true",
        help="print every file that contains forks",
    )
    parsed = parser.parse_args(args)

    prefix = koopa_prefix()

    # Activation-path directories: activate/, export/, macos/ function dirs
    # plus the shell-specific header (which contains __koopa_activate_koopa).
    activation_dirs: dict[str, list[str]] = {
        "bash": [
            os.path.join(prefix, "lang", "bash", "functions", "activate"),
            os.path.join(prefix, "lang", "bash", "functions", "export"),
            os.path.join(prefix, "lang", "bash", "functions", "macos"),
        ],
        "zsh": [
            os.path.join(prefix, "lang", "zsh", "functions", "activate"),
            os.path.join(prefix, "lang", "zsh", "functions", "export"),
            os.path.join(prefix, "lang", "zsh", "functions", "macos"),
        ],
    }
    activation_headers: dict[str, str] = {
        "bash": os.path.join(prefix, "lang", "bash", "include", "header.sh"),
        "zsh": os.path.join(prefix, "lang", "zsh", "include", "header.sh"),
    }
    # Match $(...) that aren't in comments.
    fork_re = re.compile(r"\$\(")
    comment_re = re.compile(r"^\s*#")

    failures: list[str] = []

    for shell in ("bash", "zsh"):
        alert(f"Auditing {shell} activation-path fork count.")
        total_forks = 0
        fork_details: list[tuple[str, int, str]] = []

        # Collect all .sh files from the activation directories.
        sh_files: list[str] = []
        for d in activation_dirs[shell]:
            if not os.path.isdir(d):
                continue
            for root, _dirs, files in os.walk(d):
                for f in sorted(files):
                    if f.endswith(".sh"):
                        sh_files.append(os.path.join(root, f))
        # Add the header.
        header = activation_headers[shell]
        if os.path.isfile(header):
            sh_files.append(header)

        for sh_file in sorted(sh_files):
            file_forks = 0
            try:
                with open(sh_file) as fh:
                    for line in fh:
                        if comment_re.match(line):
                            continue
                        file_forks += len(fork_re.findall(line))
            except OSError:
                continue
            if file_forks > 0:
                rel = os.path.relpath(sh_file, prefix)
                fork_details.append((rel, file_forks, sh_file))
                total_forks += file_forks

        threshold = parsed.threshold_bash if shell == "bash" else parsed.threshold_zsh
        status = "PASS" if total_forks <= threshold else "FAIL"
        print(f"  {shell}: {total_forks} forks  (threshold: {threshold})  {status}")
        if parsed.verbose:
            for rel, count, _ in sorted(fork_details, key=lambda x: -x[1]):
                print(f"    {count:3d}  {rel}")

        if total_forks > threshold:
            failures.append(f"{shell}: {total_forks} forks exceeds threshold {threshold}")

    if failures:
        print("\nActivation fork count regressions detected:", file=sys.stderr)
        for msg in failures:
            print(f"  {msg}", file=sys.stderr)
        sys.exit(1)
    alert_success("All shells meet their activation fork count thresholds.")


def _detect_color_mode_thrash(
    lines: list[str],
) -> tuple[int, list[tuple[str, str | None]]]:
    """Return the longest alternating apply-run and its (mode, timestamp) pairs.

    Parses the ``koopa configure user color-mode`` log to detect concurrent
    thrash — back-to-back applies that flip light↔dark without the stabilizing
    ``Color mode already applied:`` line in between.

    Detection is sequence-based (works on timestamped and legacy logs alike).
    Timestamps in ``[ISO-8601]`` prefix position are captured when present and
    returned for --verbose forensics.

    Rules:
    - ``Applying color mode: X`` — extends the alternating run when X differs
      from the previous apply; resets to run of 1 when X repeats.
    - ``Color mode already applied:`` — resets the run (stabilization seen).
    - Any other line is ignored.

    Returns ``(longest_run_length, mode_timestamp_pairs_for_that_run)``.

    Parameters
    ----------
    lines : list[str]
        Lines of the color-mode sync log to scan.

    Returns
    -------
    tuple[int, list[tuple[str, str | None]]]
        The length of the longest alternating apply-run, and the
        (mode, timestamp) pairs making up that run.
    """
    import re

    apply_re = re.compile(r"(?:\[(?P<ts>[^\]]+)\]\s+)?Applying color mode:\s+(?P<mode>\S+)")
    stable_re = re.compile(r"Color mode already applied:")

    best_len = 0
    best_run: list[tuple[str, str | None]] = []
    cur_run: list[tuple[str, str | None]] = []

    for line in lines:
        m = apply_re.search(line)
        if m:
            mode = m.group("mode")
            ts = m.group("ts")
            if cur_run and cur_run[-1][0] == mode:
                # Same mode repeated — machine or human mash without flip; reset.
                cur_run = [(mode, ts)]
            else:
                cur_run.append((mode, ts))
            if len(cur_run) > best_len:
                best_len = len(cur_run)
                best_run = list(cur_run)
        elif stable_re.search(line):
            # Stabilization observed — the previous apply settled; reset run.
            cur_run = []

    return best_len, best_run


def _handle_color_mode_audit(args: list[str]) -> None:
    """Handle ``koopa develop color-mode-audit``.

    Parses the color-mode sync log and fails (exit 1) when it finds thrash:
    consecutive alternating ``Applying color mode`` lines with no stabilizing
    ``Color mode already applied:`` line between them.  Threshold default of 4
    means light→dark→light→dark, which is unambiguously machine thrash — a
    human cannot toggle that fast.

    Parameters
    ----------
    args : list[str]
        Raw CLI arguments for this subcommand: ``--threshold``, ``--log``,
        and ``--verbose``.
    """
    import argparse
    import platform

    from koopa.alert import alert_note, alert_success

    parser = argparse.ArgumentParser(
        prog="koopa develop color-mode-audit",
        description=("Parse the color-mode sync log and fail if light↔dark thrash is detected."),
    )
    parser.add_argument(
        "--threshold",
        type=int,
        default=4,
        metavar="N",
        help="fail when the longest alternating apply-run is >= N (default: 4)",
    )
    parser.add_argument(
        "--log",
        metavar="PATH",
        default=None,
        help=(
            "path to the log file (default: ~/Library/Logs/koopa-color-mode-sync.log "
            "on macOS; journalctl on Linux)"
        ),
    )
    parser.add_argument(
        "--verbose",
        action="store_true",
        help="print the offending mode sequence and total apply count",
    )
    parsed = parser.parse_args(args)

    # Resolve log lines from the appropriate source.
    lines: list[str]

    if parsed.log is not None:
        if not os.path.isfile(parsed.log):
            alert_note(f"Log file not found: {parsed.log} — skipping audit.")
            print("color-mode-audit: PASS (no log)")
            return
        with open(parsed.log) as fh:
            lines = fh.readlines()
    elif platform.system() == "Darwin":
        default_log = os.path.join(
            os.path.expanduser("~"), "Library", "Logs", "koopa-color-mode-sync.log"
        )
        if not os.path.isfile(default_log):
            alert_note("No color-mode sync log found — skipping audit.")
            print("color-mode-audit: PASS (no log)")
            return
        with open(default_log) as fh:
            lines = fh.readlines()
    else:
        # Linux: read from the systemd journal.
        journalctl = shutil.which("journalctl")
        if journalctl is None:
            alert_note("journalctl not found — skipping audit.")
            print("color-mode-audit: PASS (no journalctl)")
            return
        result = subprocess.run(
            [journalctl, "--user", "-u", "koopa-color-mode-sync", "--no-pager"],
            capture_output=True,
            text=True,
            check=False,
        )
        lines = result.stdout.splitlines(keepends=True)

    longest, run = _detect_color_mode_thrash(lines)

    # Count total applies for --verbose context.
    import re

    apply_count = sum(1 for line in lines if re.search(r"Applying color mode:", line))

    if parsed.verbose:
        print(f"  Total 'Applying' lines in log: {apply_count}")
        print(f"  Longest alternating apply-run: {longest}")
        if run:
            modes = " → ".join(m for m, _ in run)
            print(f"  Run sequence: {modes}")
            timestamps = [ts for _, ts in run if ts]
            if len(timestamps) >= 2:
                print(f"  Time span: {timestamps[0]}  →  {timestamps[-1]}")

    status = "FAIL" if longest >= parsed.threshold else "PASS"
    print(f"color-mode-audit: {status}  (longest run: {longest}, threshold: {parsed.threshold})")

    if longest >= parsed.threshold:
        print(
            f"Color-mode thrash detected: {longest} consecutive alternating applies "
            f"(threshold: {parsed.threshold}).",
            file=sys.stderr,
        )
        sys.exit(1)

    alert_success("color-mode-audit passed — no thrash detected.")


_DEVELOP_HANDLERS: dict[str, Callable[[list[str]], None]] = {
    "activation-speed-test": _handle_activation_speed_test,
    "activation-fork-audit": _handle_activation_fork_audit,
    "prune-app-binaries": lambda _: _handle_prune_app_binaries(),
    "format-app-json": _handle_format_app_json,
    "update-docs": _handle_update_docs,
    "generate-completion": lambda _: _handle_generate_completion(),
    "generate-man": _handle_generate_man,
    "generate-docs": _handle_generate_docs,
    "check": _handle_check,
    "numpydoc": _handle_numpydoc,
    "pytest": _handle_pytest,
    "pyright": _handle_pyright,
    "ty": _handle_ty,
    "log": lambda _: _handle_view_latest_tmp_log_file(),
    "cache-functions": lambda _: _handle_cache_functions(),
    "edit-app-json": lambda _: _handle_edit_app_json(),
    "push-all-app-builds": lambda _: _handle_push_all_app_builds(),
    "push-app-build": _handle_push_app_build,
    "push-app-builds": lambda _: _handle_push_app_builds(),
    "push-installer": _handle_push_installer,
    "scrub-install-info": _handle_scrub_install_info,
    "shellcheck": lambda _: _handle_shellcheck(),
    "check-skills": _handle_check_skills,
    "check-app-versions": _handle_check_app_versions,
    "app-deps": _handle_app_deps,
    "app-revdeps": _handle_app_revdeps,
    "circular-dependencies": lambda _: _handle_circular_dependencies(),
    "mirror-src": _handle_mirror_src,
    "audit-src-mirror": _handle_audit_src_mirror,
    "remove-app": _handle_remove_app,
    "bump-bootstrap": _handle_bump_bootstrap,
    "bump-revision": _handle_bump_revision,
    "reset-revisions": lambda _: _handle_reset_revisions(),
    "bump-venv-version": _handle_bump_venv_version,
    "find-ignored-bin-files": _handle_find_ignored_bin_files,
    "orphan-apps": _handle_orphan_apps,
    "conda-candidates": _handle_conda_candidates,
    "color-mode-audit": _handle_color_mode_audit,
}


def handle_develop(remainder: list[str]) -> None:
    """Dispatch ``koopa develop ...`` commands.

    Parameters
    ----------
    remainder : list[str]
        Raw CLI arguments after ``koopa develop``: the subcommand name
        followed by its own arguments.
    """
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
