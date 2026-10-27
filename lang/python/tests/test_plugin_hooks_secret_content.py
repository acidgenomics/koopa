"""Tests for the koopa plugin credential guard (plugins/koopa/hooks/guard_secret_content.py).

The hook blocks a file write whose new content holds a well-known credential shape, on any
path, and lets documented placeholders and mere mentions pass.

Safety: no real credential appears here. Each credential-shaped value is assembled at
runtime from fragments, so no secret-shaped literal sits in this file. Paths live under
`tmp_path`, and the hook never writes anything.
"""

import importlib
import json
import os
import subprocess
import sys
from pathlib import Path

import pytest
from koopa.prefix import koopa_prefix

# Keep bytecode out of the plugin tree, which ships to users.
sys.dont_write_bytecode = True

_HOOKS_DIR = Path(koopa_prefix()) / "plugins" / "koopa" / "hooks"
sys.path.insert(0, str(_HOOKS_DIR))

guard_secret_content = importlib.import_module("guard_secret_content")

_HOOK_PATH = _HOOKS_DIR / "guard_secret_content.py"

# Credential-shaped values, built from fragments at runtime.
_AWS_KEY = "AKIA" + "Q7XK2M4N8P3R5T6V"
_AWS_DOC_KEY = "AKIA" + "IOSFODNN7" + "EXAMPLE"
_SIGNATURE = "9f2c4b8e1a7d3f6c0b5e8a2d4f7c1b9e" + "3a6d8f0c2b4e7a9d1f3c5b8e0a2d4f6c"
_DATABRICKS = "dapi" + "3f9a2c7e1b8d4f6a0c5e9b2d7f1a3c8e"
_GITHUB = "ghp_" + "R8kL2mN9pQ4sT7vW1xY5zA3bC6dE0fG2hJ4k"
_GITHUB_PAT = "github_pat_" + "11ABCDEFG0aBcDeFgHiJkL_mNoPqRsTuVwXyZ0123456789aBcDeFgHiJkLmNoPq"
_JWT = "eyJhbGciOiJIUzI1NiJ9" + ".eyJzdWIiOiIxMjM0In0.dBjftJeZ4CVP"
_PEM = (
    "-----BEGIN " + "RSA PRIVATE KEY-----\n"
    "MIIEowIBAAKCAQEA7xK3pQ9vR2mL8nT4wY6zB1cD5fH0jG3kS7uV9aX2eI4oP8qR\n"
    "-----END " + "RSA PRIVATE KEY-----\n"
)
_CLEAN = "nothing to see here\n"


# ---------------------------------------------------------------------------
# helpers
# ---------------------------------------------------------------------------


def _run(stdin: str) -> subprocess.CompletedProcess[str]:
    """Run the real hook entry point, returning its result even for a nonzero exit."""
    env = {**os.environ, "PYTHONDONTWRITEBYTECODE": "1"}
    try:
        return subprocess.run(
            [sys.executable, "-B", str(_HOOK_PATH)],
            input=stdin,
            capture_output=True,
            text=True,
            check=True,
            env=env,
        )
    except subprocess.CalledProcessError as error:
        return subprocess.CompletedProcess(error.cmd, error.returncode, error.stdout, error.stderr)


def _write(path: Path, content: str) -> str:
    """Claude Code `Write` payload."""
    return json.dumps(
        {"tool_name": "Write", "tool_input": {"file_path": str(path), "content": content}}
    )


def _edit(path: Path, new: str, old: str = "") -> str:
    """Claude Code `Edit` payload."""
    return json.dumps(
        {
            "tool_name": "Edit",
            "tool_input": {"file_path": str(path), "new_string": new, "old_string": old},
        }
    )


def _patch(*files: tuple[Path, str]) -> str:
    """Copilot `apply_patch` envelope that adds each `(path, content)` file."""
    lines = ["*** Begin Patch"]
    for path, content in files:
        lines.append(f"*** Add File: {path}")
        lines += [f"+{line}" for line in content.splitlines()]
    lines.append("*** End Patch")
    return json.dumps({"tool_input": "\n".join(lines)})


# ---------------------------------------------------------------------------
# find_credential
# ---------------------------------------------------------------------------


@pytest.mark.parametrize(
    ("text", "kind"),
    [
        (f"key = {_AWS_KEY}", "an AWS access key ID"),
        (f"https://b.s3.amazonaws.com/k?X-Amz-Signature={_SIGNATURE}", "a presigned URL signature"),
        (f"token: {_DATABRICKS}", "a Databricks token"),
        (f"export GH_TOKEN={_GITHUB}", "a GitHub token"),
        (f"GH_TOKEN={_GITHUB_PAT}", "a GitHub token"),
        (f"Authorization: Bearer {_JWT}", "a bearer credential"),
        (f"curl -H 'authorization: bearer {_JWT}'", "a bearer credential"),
        (_PEM, "a private key"),
    ],
)
def test_finds_each_credential_kind(text: str, kind: str) -> None:
    """Each credential shape is found and named, on the line it sits on."""
    assert guard_secret_content.find_credential(text) == (kind, 1)


@pytest.mark.parametrize(
    "text",
    [
        pytest.param(f"aws_access_key_id = {_AWS_DOC_KEY}", id="aws-doc-example-key"),
        pytest.param("token: dapi" + "0" * 32, id="zeros-placeholder"),
        pytest.param("GH_TOKEN=ghp_" + "x" * 36, id="repeated-char-placeholder"),
        pytest.param("Authorization: Bearer " + "x" * 24, id="repeated-char-bearer"),
        pytest.param("Pass the X-Amz-Signature= query parameter.", id="parameter-name-only"),
        pytest.param("Send Authorization: Bearer <token>", id="angle-template"),
        pytest.param("Send Authorization: Bearer ${GITHUB_TOKEN}", id="shell-template"),
        pytest.param('headers = {"Authorization": f"Bearer {token}"}', id="fstring-template"),
        pytest.param(
            "A key file starts with -----BEGIN " + "OPENSSH PRIVATE KEY-----.",
            id="header-only",
        ),
        pytest.param(
            "-----BEGIN " + "PRIVATE KEY-----\nMIIEvQIBADAN...\n-----END " + "PRIVATE KEY-----",
            id="truncated-key",
        ),
        pytest.param(_CLEAN, id="clean"),
    ],
)
def test_placeholders_and_mentions_pass(text: str) -> None:
    """Documented placeholders and text that only names a shape are not credentials."""
    assert guard_secret_content.find_credential(text) is None


def test_line_number_is_within_the_new_text() -> None:
    """The reported line counts from the start of the written text."""
    text = "line one\nline two\n" + f"key = {_AWS_KEY}\n"
    assert guard_secret_content.find_credential(text) == ("an AWS access key ID", 3)


def test_key_inside_a_longer_token_is_not_matched() -> None:
    """An AKIA run glued to more letters or digits is not an access key ID."""
    assert guard_secret_content.find_credential("X" + _AWS_KEY + "9") is None


# ---------------------------------------------------------------------------
# entry point: payload shapes
# ---------------------------------------------------------------------------


def test_write_with_a_credential_blocks_without_echoing_it(tmp_path: Path) -> None:
    """A blocked write names the kind, file, and line, never the value."""
    result = _run(_write(tmp_path / "notes.md", f"# Notes\n\nkey = {_AWS_KEY}\n"))
    assert result.returncode == 2
    assert "an AWS access key ID" in result.stderr
    assert "line 3" in result.stderr
    assert str(tmp_path / "notes.md") in result.stderr
    assert _AWS_KEY not in result.stderr


def test_clean_write_passes(tmp_path: Path) -> None:
    """A write with no credential exits 0 silently."""
    result = _run(_write(tmp_path / "notes.md", _CLEAN))
    assert result.returncode == 0
    assert result.stderr == ""


def test_any_path_is_checked(tmp_path: Path) -> None:
    """There is no publishable-repo condition: a scratch file outside git blocks too."""
    outside = tmp_path / "scratch" / "x.txt"
    assert _run(_write(outside, f"t={_DATABRICKS}")).returncode == 2


def test_edit_checks_only_the_new_string(tmp_path: Path) -> None:
    """Adding a credential blocks; replacing one with a reference passes."""
    path = tmp_path / "a.py"
    assert _run(_edit(path, new=f"TOKEN = '{_GITHUB}'", old="TOKEN = ''")).returncode == 2
    assert _run(_edit(path, new="TOKEN = os.environ['GH_TOKEN']", old=_GITHUB)).returncode == 0


def test_multiedit_edits_are_checked(tmp_path: Path) -> None:
    """MultiEdit's `edits[].new_string`, which the shared adapter skips, is read."""
    payload = json.dumps(
        {
            "tool_name": "MultiEdit",
            "tool_input": {
                "file_path": str(tmp_path / "a.py"),
                "edits": [
                    {"old_string": "a", "new_string": "b"},
                    {"old_string": "c", "new_string": f"auth = 'Bearer {_JWT}'"},
                ],
            },
        }
    )
    assert _run(payload).returncode == 2


def test_notebook_cell_source_is_checked(tmp_path: Path) -> None:
    """NotebookEdit's `new_source`, which the shared adapter skips, is read."""
    payload = json.dumps(
        {
            "tool_name": "NotebookEdit",
            "tool_input": {
                "notebook_path": str(tmp_path / "n.ipynb"),
                "new_source": f"token = '{_DATABRICKS}'",
            },
        }
    )
    result = _run(payload)
    assert result.returncode == 2
    assert "n.ipynb" in result.stderr


def test_copilot_create_and_edit_shapes(tmp_path: Path) -> None:
    """Copilot `create` (`file_text`) and `edit` (`new_str`) are both read."""
    path = str(tmp_path / "a.txt")
    create = json.dumps({"tool_input": {"path": path, "file_text": _PEM}})
    edit = json.dumps({"tool_input": {"path": path, "old_str": _CLEAN, "new_str": _PEM}})
    assert _run(create).returncode == 2
    assert _run(edit).returncode == 2


def test_copilot_batch_with_the_credential_in_a_later_call(tmp_path: Path) -> None:
    """A credential hidden in a later `toolCalls[]` entry still blocks."""
    path = str(tmp_path / "a.txt")
    payload = json.dumps(
        {
            "toolCalls": [
                {"args": {"path": path, "file_text": _CLEAN}},
                {"args": {"path": path, "file_text": f"k={_AWS_KEY}"}},
            ]
        }
    )
    assert _run(payload).returncode == 2


def test_apply_patch_blocks_when_any_file_holds_a_credential(tmp_path: Path) -> None:
    """Each file in a patch envelope is judged; the message names the offending one."""
    both = _patch((tmp_path / "a.txt", _CLEAN), (tmp_path / "b.txt", f"k={_GITHUB}"))
    result = _run(both)
    assert result.returncode == 2
    assert "b.txt" in result.stderr
    clean = _patch((tmp_path / "a.txt", _CLEAN), (tmp_path / "b.txt", _CLEAN))
    assert _run(clean).returncode == 0


def test_delete_is_not_checked(tmp_path: Path) -> None:
    """A delete writes no new content, so it is never blocked."""
    patch = "\n".join(
        ["*** Begin Patch", f"*** Delete File: {tmp_path / 'a.txt'}", "*** End Patch"]
    )
    assert _run(json.dumps({"tool_input": patch})).returncode == 0


@pytest.mark.parametrize("stdin", ["", "   ", "{not json", "[1, 2]", '{"tool_input": 7}'])
def test_empty_or_malformed_stdin_passes(stdin: str) -> None:
    """Empty or unreadable input exits 0, like the other write guards."""
    assert _run(stdin).returncode == 0
