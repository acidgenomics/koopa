#!/usr/bin/env python3
"""PreToolUse hook: block a write that contains a configured keyword in a publishable repo.

Inert by default. It reads the same git config keys as the global `pre-commit` hook and
does nothing unless at least one keyword key has a value, so the plugin ships no keywords.

- `koopa.keywords`: checked in the file path and in the new content.
- `koopa.contentKeywords`: checked in the new content only (for a keyword, such as a
  username, that appears in every absolute path under the user's home).
- `koopa.allowedRemotes`: remotes where the keywords are legitimate. An entry matches
  when it is a case-sensitive substring of the `origin` remote URL.

Deprecated aliases, read for one more release and then removed: `koopa.restrictedTokens`,
`koopa.restrictedTokensContentOnly` and `koopa.corpRemoteAllowlist`. For each setting the hook
uses the union of the new key and its old alias (de-duplicated, order preserved), so a config
renamed at a different time than this hook never leaves the guard silent.

Each value is a case-insensitive extended regular expression. A match must not touch an
ASCII letter or digit on either side, so `acmecorp` does not match `acmecorporation`. Only
the NEW content (`FileTarget.body`) is checked, never the text being replaced, so an edit
near a line that already holds a keyword is not blocked for content it did not introduce.

A match blocks only when the target is in a publishable place. The path must be absolute,
its directory must exist and sit inside a git work tree, the `origin` remote must not match
`koopa.allowedRemotes`, and the path must not be gitignored. Every git call has a
5 second timeout, and any git failure allows the write.

Fails open on any unexpected error (one line on stderr, exit 0): the git `pre-commit` hook
is the backstop. A block prints the reason on stderr and exits 2. Covers Claude Code
`Write`/`Edit`, Copilot CLI `edit`/`create`, and `apply_patch` envelopes naming several
files (each target is judged under its own path). A delete, or the source side of a move,
is never checked.

Ships in the koopa plugin under `hooks/`. Needs `hook_adapter.py` beside it, and Python
3.10 or newer (annotations use `X | None`).
"""

import os
import re
import subprocess
import sys

from hook_adapter import targets_or_skip

_TIMEOUT = 5
_BOUNDARY_PRE = r"(?:^|[^A-Za-z0-9])(?:"
_BOUNDARY_SUF = r")(?:[^A-Za-z0-9]|$)"
_PATH_KEY = "koopa.keywords"
_CONTENT_KEY = "koopa.contentKeywords"
_ALLOWLIST_KEY = "koopa.allowedRemotes"
# Deprecated aliases of the three keys above; remove in a later release.
_OLD_PATH_KEY = "koopa.restrictedTokens"
_OLD_CONTENT_KEY = "koopa.restrictedTokensContentOnly"
_OLD_ALLOWLIST_KEY = "koopa.corpRemoteAllowlist"


def _git(args: list[str], cwd: str) -> str | None:
    """Run git and return stripped stdout, or None on any failure (nonzero, timeout, no git)."""
    try:
        result = subprocess.run(
            ["git", *args],
            cwd=cwd,
            capture_output=True,
            text=True,
            check=True,
            timeout=_TIMEOUT,
        )
    except (subprocess.CalledProcessError, subprocess.TimeoutExpired, OSError):
        return None
    return result.stdout.strip()


def _config_values(key: str) -> list[str]:
    """Return every non-blank value of a git config key, read from a neutral directory."""
    out = _git(["config", "--get-all", key], os.path.abspath(os.sep))
    if not out:
        return []
    return [line.strip() for line in out.splitlines() if line.strip()]


def _merged_values(key: str, old_key: str) -> list[str]:
    """Return the de-duplicated union of a key and its deprecated alias, order preserved."""
    return list(dict.fromkeys(_config_values(key) + _config_values(old_key)))


def _valid(patterns: list[str], key: str) -> list[str]:
    """Drop patterns that do not compile, with one warning line per dropped pattern."""
    valid: list[str] = []
    for pattern in patterns:
        try:
            re.compile(pattern)
        except re.error:
            print(f"guard_keywords: skipping an invalid pattern in {key}", file=sys.stderr)
            continue
        valid.append(pattern)
    return valid


def _compile(patterns: list[str]) -> re.Pattern[str] | None:
    """Join already-valid patterns into one boundary-wrapped matcher."""
    if not patterns:
        return None
    joined = "|".join(f"(?:{pattern})" for pattern in patterns)
    try:
        return re.compile(_BOUNDARY_PRE + joined + _BOUNDARY_SUF, re.IGNORECASE | re.MULTILINE)
    except re.error:
        return None  # e.g. a group-numbering clash between valid patterns: skip, never crash


def _is_publishable(path: str) -> bool:
    """True when a write to `path` would land in a repository that is not private or ignored."""
    directory = os.path.dirname(path)
    if not os.path.isabs(path) or not os.path.isdir(directory):
        return False
    if _git(["rev-parse", "--is-inside-work-tree"], directory) != "true":
        return False
    origin = _git(["remote", "get-url", "origin"], directory) or ""
    if any(entry in origin for entry in _merged_values(_ALLOWLIST_KEY, _OLD_ALLOWLIST_KEY)):
        return False
    try:
        subprocess.run(
            ["git", "check-ignore", "-q", "--", path],
            cwd=directory,
            capture_output=True,
            check=True,
            timeout=_TIMEOUT,
        )
    except subprocess.CalledProcessError as error:
        return error.returncode == 1  # 1 = not ignored; anything else is a git failure: allow
    except (subprocess.TimeoutExpired, OSError):
        return False
    return False  # ignored


def _reason(path: str) -> str:
    """Build the generic block message for a write to `path`."""
    return (
        f"Blocked: writing {path!r} contains a configured keyword ({_PATH_KEY}) and the "
        f"target repository is publishable. Move the content to a private repository, "
        f"or add the remote to {_ALLOWLIST_KEY}."
    )


def main() -> None:
    """Read the PreToolUse payload from stdin and block a write holding a restricted keyword."""
    targets = targets_or_skip(sys.stdin.read())
    if not targets:
        return
    path_values = _merged_values(_PATH_KEY, _OLD_PATH_KEY)
    content_values = _merged_values(_CONTENT_KEY, _OLD_CONTENT_KEY)
    if not path_values and not content_values:
        return  # inert: no keywords configured
    path_valid = _valid(path_values, _PATH_KEY)
    path_re = _compile(path_valid)
    content_re = _compile(path_valid + _valid(content_values, _CONTENT_KEY))
    for target in targets:
        if target.verb in ("delete", "move_from"):
            continue
        found = (path_re is not None and path_re.search(target.path) is not None) or (
            content_re is not None and content_re.search(target.body) is not None
        )
        if found and _is_publishable(target.path):
            print(_reason(target.path), file=sys.stderr)
            sys.exit(2)


if __name__ == "__main__":
    try:
        main()
    except Exception as error:
        # Fail open: the git pre-commit hook is the backstop.
        print(
            f"guard_keywords: skipped after an internal error ({type(error).__name__})",
            file=sys.stderr,
        )
        sys.exit(0)
