#!/usr/bin/env python3
"""PreToolUse hook: redirect a session-report write to a detected Obsidian vault.

Session reports belong in an Obsidian vault, not in a repository's `reports/`
directory (often gitignored, so invisible to git and to everyone else). There is
no single vault path to assume, so this hook denies a report write only when
`obsidian_vault.resolve_vault_dir()` finds a vault on this machine (env override,
or auto-detected from Obsidian's own config). With no vault detected, the write
proceeds: a project-local `reports/` is then the only destination.

Scope is narrow, because a project can have a real `reports/` package or folder.
A write is a session report only when its path has a dated folder under `reports/`
(nested `reports/YYYY/MM/DD/` or flat `reports/YYYY-MM-DD/`), or sits directly
under the top-level `reports/` of the project (`CLAUDE_PROJECT_DIR`, else the
working directory). `src/reports/builder.py` is never touched. The deny reason
names the vault path to use instead.

Fails open on empty or non-JSON stdin (via `hook_adapter.targets_or_deny`). A payload
whose tool input it cannot read exits 2, because a guard should not pass on input it
cannot inspect. Also covers Copilot CLI's `apply_patch`, whose patch envelope can name
several files, including a moved file's destination.
A delete, or the source side of a move, is never checked: that is the migration
this hook exists to encourage.

Ships in the koopa plugin under `hooks/`. Needs `hook_adapter.py` and
`obsidian_vault.py` beside it, and Python 3.10 or newer (annotations use `X | None`).
"""

import os
import re
import sys

from hook_adapter import targets_or_deny
from obsidian_vault import resolve_vault_dir

_TOP_LEVEL_REPORTS_RE = re.compile(r"^reports/.+")
_DAY_FOLDER_RE = re.compile(r"reports/(\d{4})/(\d{2})/(\d{2})/")
_FLAT_DAY_FOLDER_RE = re.compile(r"reports/(\d{4})-(\d{2})-(\d{2})/")


def decide(file_path: str) -> str | None:
    """Return a deny reason, or None to let the write proceed."""
    if not file_path:
        return None
    if not _is_session_report_path(file_path):
        return None
    vault_dir = resolve_vault_dir()
    if vault_dir is None:
        return None  # no vault detected on this machine: reports/ is the safe fallback
    return (
        f"Blocked: {file_path!r} writes into a reports/ directory. "
        f"This machine has an Obsidian vault at {vault_dir!r}: session "
        f"reports go there instead. Use {_to_vault_path(file_path, vault_dir)} instead."
    )


def _is_session_report_path(file_path: str) -> bool:
    """True for a dated `reports/` folder anywhere, or the project's top-level `reports/`."""
    if _DAY_FOLDER_RE.search(file_path) or _FLAT_DAY_FOLDER_RE.search(file_path):
        return True
    root = os.environ.get("CLAUDE_PROJECT_DIR") or os.getcwd()
    relative = os.path.relpath(file_path, root) if os.path.isabs(file_path) else file_path
    return _TOP_LEVEL_REPORTS_RE.match(relative.replace(os.sep, "/")) is not None


def _to_vault_path(file_path: str, vault_dir: str) -> str:
    """Turn a `reports/...` path into its vault equivalent, if the date is derivable."""
    match = _DAY_FOLDER_RE.search(file_path) or _FLAT_DAY_FOLDER_RE.search(file_path)
    if match is None:
        return f"{vault_dir}/YYYY/MM/DD/<slug>.md"
    year, month, day = match.groups()
    rest = file_path[match.end() :]
    return f"{vault_dir}/{year}/{month}/{day}/{rest}"


def main() -> None:
    """Read the PreToolUse payload from stdin and emit a deny decision if needed."""
    for target in targets_or_deny(sys.stdin.read()):
        # A delete, or a move's source side, names the path being removed. Only a
        # genuinely new write is checked; `move_to`'s destination still is.
        if target.verb in ("delete", "move_from"):
            continue
        reason = decide(target.path)
        if reason is not None:
            print(reason, file=sys.stderr)
            sys.exit(2)


if __name__ == "__main__":
    try:
        main()
    except Exception as error:
        # Fail open, like the other convenience guards: a bug here must not lock every write.
        print(
            f"guard_report_path: skipped after an internal error ({type(error).__name__})",
            file=sys.stderr,
        )
        sys.exit(0)
