r"""PreToolUse hook: block reads and edits of .env files.

Two paths, because a model can reach the same file two ways:

- File tools. Covers Claude Code's dict `tool_input` (`file_path`), Copilot
  CLI's `view` (dict, keyed on `path`), `edit`/`create` (`new_str`/
  `file_text`), and `apply_patch` (a freeform string patch envelope that can
  touch several files) via `hook_adapter`. See that module's docstring for
  why a Claude-only reader crashes on Copilot's string shape.
- Shell commands. A matcher on file tools alone never fires when the model
  runs `cat .env` through its shell tool instead, which Copilot CLI did in a
  live test. A command is blocked when it names `.env` or `.env.local` as a
  path component. A match is a token check, not a verb check: a verb list
  would miss `python -c "open('.env')"`, `grep KEY .env`, and similar.

One exemption. Loading the file into the shell or a Python process does not
show its contents to the model, and some projects require it (`set -a &&
source .env && set +a`, because their CLI does not read the file itself). So
these forms are removed before the scan:

- `source <path>/.env` or `. <path>/.env` at the start of a command (after
  `;`, `&`, `|`, `(`, `{`, or a newline). The start-of-command rule stops
  `cat . .env` from passing as a "dot-source".
- `load_dotenv(...)`.

Only the matched span is removed. Any other mention that remains still
blocks, so `source .env && cat .env` is denied.

False positives are accepted over misses: `ls .env` is blocked too. These
names do not match: `.envrc`, `.env.example`, `.env.local.bak`, `.venv`, and
a directory named `.env/` such as a virtualenv.

Known limit. This is a text check on the command as written. It cannot see
through `cat $(printf '\056env')`, a glob such as `cat .e*`, or `source .env;
echo $SECRET`. It stops the casual route a model takes on its own, not a
deliberate bypass.

Wire this script on the shell tool as well as the file tools.

Ships in the koopa plugin under `hooks/`. Needs `hook_adapter.py` beside it, and Python 3.10
or newer.
"""

import re
import sys
from pathlib import Path

from hook_adapter import load_payload, read_commands, targets_or_deny

_ENV_NAMES = {".env", ".env.local"}

# `.env` or `.env.local` as a whole path component. The lookbehind rejects a
# longer name that merely ends in it (`x.env`, `my-.env`) and a regex escape
# such as `\.env`. The lookahead rejects a longer name that starts with it
# (`.envrc`, `.env.example`, `.env.local.bak`) and a directory
# (`.env/bin/activate`).
_ENV_IN_COMMAND = re.compile(r"(?<![A-Za-z0-9_.\\-])\.env(?:\.local)?(?![A-Za-z0-9_.\-/])")

# Forms that load the file without printing it. The shell form is anchored to
# the start of a command so that an argument position cannot qualify.
_LOAD_SHELL = (
    r"(?:^|(?<=[;&|(\n{]))[ \t]*(?:source|\.)[ \t]+"
    r"[\"']?(?:[^\s;&|\"'<>()]*/)?\.env(?:\.local)?[\"']?(?=[\s;&|)]|$)"
)
_LOAD_PYTHON = r"\bload_dotenv\s*\([^)]*\)"
_ENV_LOAD = re.compile(f"{_LOAD_SHELL}|{_LOAD_PYTHON}", re.MULTILINE)


def _names_env_file(command: str) -> bool:
    """True if the command names an env file other than to load it."""
    return bool(_ENV_IN_COMMAND.search(_ENV_LOAD.sub(" ", command)))


def main() -> None:
    """Block reads and edits of .env files."""
    raw = sys.stdin.read()

    for target in targets_or_deny(raw):
        if Path(target.path).name in _ENV_NAMES:
            print(
                "Blocked: .env files contain credentials and must not be edited.", file=sys.stderr
            )
            sys.exit(2)

    payload = load_payload(raw)
    if payload is None:
        return
    for command in read_commands(payload):
        if _names_env_file(command):
            print(
                "Blocked: .env files contain credentials and must not be read or "
                "edited, including through a shell command. Loading one with "
                "`source` is allowed.",
                file=sys.stderr,
            )
            sys.exit(2)


if __name__ == "__main__":
    try:
        main()
    except SystemExit:
        raise
    except Exception as error:
        # Deny on any unexpected bug rather than let a traceback through:
        # Claude Code treats a non-2 exit as non-blocking, so an uncaught
        # exception here would silently let a credential read pass.
        print(f"Blocked: guard_env_files internal error: {error}", file=sys.stderr)
        sys.exit(2)
