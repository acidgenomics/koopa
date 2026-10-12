"""Shared adapter: normalize Claude Code and Copilot CLI hook input into file targets.

Claude Code's `Write`/`Edit` hooks send `tool_input` as a dict with `file_path`
(and `content`/`new_string`/`old_string`). Copilot CLI's `view` (read) sends a
dict keyed on `path` instead, and its `edit`/`create` tools use `new_str`/
`old_str`/`file_text` rather than Claude's field names. Copilot CLI's
`apply_patch` (its other write tool) sends `tool_input` as a **string**: a
freeform patch envelope (`*** Begin Patch` ... `*** End Patch`), which can
touch several files in one call, can move a file (`*** Move to: `), and uses
paths relative to the call's own `cwd`. A hook written for Claude's shape
alone crashes on that string with `AttributeError: 'str' object has no
attribute 'get'` -- confirmed live in a Copilot session, which denies every
write because Copilot runs hooks fail-closed.

This module gives every file-touching hook one place to turn any of these
shapes into a flat list of `FileTarget`. Callers choose a fail policy
explicitly:

- `targets_or_deny` (PreToolUse): absent input exits 0 (nothing to guard);
  present-but-unreadable input exits 2 (a write we cannot inspect must not
  pass a credential/path check).
- `targets_or_skip` (PostToolUse): absent or unreadable input returns `[]`.
  The tool already ran; a PostToolUse hook cannot undo it, so it only skips
  its own side effect rather than erroring.

Deployed from the public dotfiles tree to `~/.agents/hooks/hook_adapter.py`.
Hooks in the private work tree import it from that deployed path (both trees
land in the same flat `~/.agents/hooks/` directory), so this module must stay
free of anything tree-specific.
"""

import json
import os
import sys
from dataclasses import dataclass

# The macOS system `python3` (/usr/bin/python3) is 3.9 and cannot evaluate the
# `X | None` annotations below. Stop with a readable message instead of an
# import-time TypeError. Exit 1 is non-blocking, like the crash it replaces.
if sys.version_info < (3, 10):
    sys.exit(
        f"hook_adapter: Python 3.10 or newer is required, found {sys.version.split()[0]} "
        f"({sys.executable}). Put a newer python3 first on PATH."
    )

_ADD = "*** Add File: "
_UPDATE = "*** Update File: "
_DELETE = "*** Delete File: "
_MOVE = "*** Move to: "
_BEGIN = "*** Begin Patch"
_END = "*** End Patch"
_HEADERS = (_ADD, _UPDATE, _DELETE)

_VERB_BY_HEADER = {
    _ADD: "add",
    _UPDATE: "update",
    _DELETE: "delete",
}


class HookInputError(Exception):
    """Input is present but cannot be inspected. Callers must deny the call."""


@dataclass(frozen=True)
class FileTarget:
    """One file a tool call would touch."""

    path: str
    body: str
    verb: str  # "plain" | "add" | "update" | "delete" | "move_from" | "move_to"
    # Whether `body` is only a FRAGMENT of the target file (Edit's new_string;
    # an apply_patch hunk's added lines, with removed/context lines dropped)
    # rather than the whole document. A position computed within a fragment
    # (e.g. "line 0 of body") carries no reliable meaning about where that
    # content actually lands in the real file -- callers using position to
    # distinguish a document header from a footer must check this first.
    is_fragment: bool = True
    # Claude Code's Edit tool (and Copilot's `edit`) also sends the exact text
    # being replaced (`old_string`/`old_str`). A caller can find it in the
    # on-disk file (unmodified, since this runs PreToolUse) to recover the
    # fragment's real document-relative position. None when no such anchor
    # exists (Write/create, or an apply_patch hunk).
    old_string: str | None = None


def load_payload(raw: str) -> dict | None:
    """Parse hook stdin. Return None when there is nothing to inspect."""
    if not raw.strip():
        return None
    try:
        payload = json.loads(raw)
    except (json.JSONDecodeError, ValueError):
        return None
    if not isinstance(payload, dict):
        return None
    return payload


def _resolve(path: str, cwd: str | None) -> str:
    """Resolve a possibly-relative path against the hook payload's own cwd.

    Copilot CLI's `apply_patch` paths (and some tool_input `path` values) are
    relative to the call's `cwd`, not the process's own working directory.
    """
    if not path or os.path.isabs(path) or not cwd:
        return path
    return os.path.join(cwd, path)


def _rovo_body_text(tool_input: dict) -> tuple[str, bool] | None:
    """Extract (body_text, is_fragment) from an Atlassian Rovo Confluence write.

    The Rovo `createConfluenceContent`/`updateConfluenceContent` tools carry
    no `file_path` and no flat `content` string, so the plain extraction
    below would read an empty body and let a body-inspecting hook pass by
    default. Their body arrives in one of two shapes: `body` as
    `{"format": ..., "value": ...}`, which replaces the whole document, or
    `edits` as an array of granular operations, each carrying its own
    `value` fragment. Returns None when neither shape is present, so a
    non-Rovo payload is untouched.
    """
    body = tool_input.get("body")
    if isinstance(body, dict):
        value = body.get("value")
        if isinstance(value, str) and value:
            return value, False
    edits = tool_input.get("edits")
    if isinstance(edits, list):
        values = [
            edit["value"]
            for edit in edits
            if isinstance(edit, dict) and isinstance(edit.get("value"), str) and edit["value"]
        ]
        if values:
            return "\n".join(values), True
    return None


def _dict_target(tool_input: dict, cwd: str | None = None) -> FileTarget:
    path = tool_input.get("file_path") or tool_input.get("path") or ""
    if not isinstance(path, str):
        raise HookInputError("file_path/path must be a string")
    path = _resolve(path, cwd)
    content = tool_input.get("content")
    file_text = tool_input.get("file_text")
    new_string = tool_input.get("new_string") or tool_input.get("new_str")
    content_file = tool_input.get("content_file")
    rovo_body = _rovo_body_text(tool_input)
    old_string: str | None = None
    # content/content_file/file_text are the WHOLE new document (Write/create
    # style); new_string/new_str is only the replacement fragment (Edit
    # style) -- position within it says nothing about position in the real
    # file.
    if content:
        body = str(content)
        is_fragment = False
    elif file_text:
        body = str(file_text)
        is_fragment = False
    elif rovo_body is not None:
        body, is_fragment = rovo_body
    elif new_string:
        body = str(new_string)
        is_fragment = True
        raw_old_string = tool_input.get("old_string") or tool_input.get("old_str")
        if isinstance(raw_old_string, str):
            old_string = raw_old_string
    elif content_file and isinstance(content_file, str) and os.path.exists(content_file):
        # os.path.exists() above is a TOCTOU check only -- the file can
        # vanish or become unreadable (permissions, a directory, a broken
        # symlink) before this open() runs. Translate that into
        # HookInputError so it flows through the caller's existing
        # 0/2/soft-skip contract instead of an uncaught OSError.
        try:
            with open(content_file, encoding="utf-8") as f:
                body = f.read()
        except OSError as error:
            raise HookInputError(
                f"content_file {content_file!r} could not be read: {error}"
            ) from error
        is_fragment = False
    else:
        body = ""
        is_fragment = True
    return FileTarget(
        path=path, body=body, verb="plain", is_fragment=is_fragment, old_string=old_string
    )


def _parse_patch_envelope(text: str, cwd: str | None = None) -> list[FileTarget]:
    lines = text.splitlines()
    if len(lines) < 2 or lines[0] != _BEGIN or lines[-1] != _END:
        raise HookInputError("unrecognized freeform patch envelope")

    targets: list[FileTarget] = []
    verb: str | None = None
    path: str | None = None
    body_lines: list[str] = []

    def _flush() -> None:
        if verb is not None and path is not None:
            # "add" (a brand-new file) has its "+" lines as the WHOLE file.
            # "update"/"move_to" only include the changed hunk's added
            # lines -- removed/context lines are dropped above, so position
            # within body_lines is fragment-relative, not document-relative.
            targets.append(
                FileTarget(
                    path=path,
                    body="\n".join(body_lines),
                    verb=verb,
                    is_fragment=verb != "add",
                )
            )

    for line in lines[1:-1]:
        header = next((h for h in _HEADERS if line.startswith(h)), None)
        if header is not None:
            _flush()
            verb = _VERB_BY_HEADER[header]
            path = _resolve(line[len(header) :], cwd)
            body_lines = []
            continue
        if line.startswith(_MOVE):
            if verb != "update" or path is None:
                raise HookInputError("misplaced 'Move to' directive")
            targets.append(FileTarget(path=path, body="", verb="move_from"))
            path = _resolve(line[len(_MOVE) :], cwd)
            verb = "move_to"
            continue
        if verb is None:
            raise HookInputError("patch content without a preceding file header")
        if line.startswith("+"):
            body_lines.append(line[1:])
        elif line.startswith(("-", "@@")) or line == "*** End of File" or line.startswith(" "):
            continue
        else:
            raise HookInputError(f"unrecognized patch line: {line!r}")

    _flush()
    if not targets:
        raise HookInputError("patch has no file operations")
    return targets


def read_targets(payload: dict) -> list[FileTarget]:
    """Every file this call would touch. Raise HookInputError when unreadable."""
    raw_cwd = payload.get("cwd")
    cwd = raw_cwd if isinstance(raw_cwd, str) else None

    if "tool_input" in payload:
        tool_input = payload["tool_input"]
        if isinstance(tool_input, dict):
            return [_dict_target(tool_input, cwd)]
        if isinstance(tool_input, str):
            return _parse_patch_envelope(tool_input, cwd)
        raise HookInputError(
            f"tool_input must be an object or a string, got {type(tool_input).__name__}"
        )

    if "toolCalls" in payload:
        tool_calls = payload["toolCalls"]
        if not isinstance(tool_calls, list):
            raise HookInputError("toolCalls must be a list")
        targets: list[FileTarget] = []
        for call in tool_calls:
            if not isinstance(call, dict):
                raise HookInputError("each toolCalls entry must be an object")
            args = call.get("args")
            if args is None:
                continue
            targets.extend(read_targets({"tool_input": args, "cwd": cwd}))
        return targets

    return []


def read_commands(payload: dict) -> list[str]:
    """Every shell command string this call would run.

    Mirrors read_targets()'s toolCalls[] unwrapping, but for the `command`
    field a Bash-matcher hook reads instead of a file-edit field: reading
    `tool_input.command` directly sees nothing at all for Copilot's batched
    parallel-call shape, and silently allows a command it should have
    blocked. Unlike read_targets, this never raises: it returns an empty
    list for anything it cannot read, so a caller decides its own policy.
    """
    if "tool_input" in payload:
        tool_input = payload["tool_input"]
        if isinstance(tool_input, dict):
            command = tool_input.get("command")
            return [command] if isinstance(command, str) else []
        return []

    if "toolCalls" in payload:
        tool_calls = payload["toolCalls"]
        if not isinstance(tool_calls, list):
            return []
        commands: list[str] = []
        for call in tool_calls:
            if not isinstance(call, dict):
                continue
            args = call.get("args")
            if isinstance(args, dict):
                commands.extend(read_commands({"tool_input": args}))
        return commands

    return []


def targets_or_deny(raw: str) -> list[FileTarget]:
    """PreToolUse entry point. Exit 0 on absent input, exit 2 on unreadable input."""
    payload = load_payload(raw)
    if payload is None:
        sys.exit(0)
    try:
        return read_targets(payload)
    except HookInputError as error:
        print(f"Blocked: invalid file-hook input: {error}", file=sys.stderr)
        sys.exit(2)


def targets_or_skip(raw: str) -> list[FileTarget]:
    """PostToolUse entry point. Returns [] on absent or unreadable input."""
    payload = load_payload(raw)
    if payload is None:
        return []
    try:
        return read_targets(payload)
    except HookInputError:
        return []
