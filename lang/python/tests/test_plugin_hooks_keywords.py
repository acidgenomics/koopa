"""Tests for the koopa plugin keyword guard (plugins/koopa/hooks/guard_keywords.py).

The hook blocks a Write/Edit that would contain a configured restricted keyword in a
publishable repository. It reads three git config keys (`koopa.keywords`,
`koopa.contentKeywords`, `koopa.allowedRemotes`) and is inert without them.

Safety: every token in this file is a made-up placeholder (`acmecorp`, `jdoe42`). Each test
isolates git configuration with `GIT_CONFIG_GLOBAL` pointing at a file under `tmp_path`,
`GIT_CONFIG_SYSTEM=/dev/null`, and a `HOME` under `tmp_path`, so the real user and system
config are never read. Git runs only inside `tmp_path` repositories. Nothing is written
by the hook itself.
"""

import importlib
import io
import json
import os
import runpy
import subprocess
import sys
from pathlib import Path

import pytest
from koopa.prefix import koopa_prefix

# Keep bytecode out of the plugin tree, which ships to users.
sys.dont_write_bytecode = True

_HOOKS_DIR = Path(koopa_prefix()) / "plugins" / "koopa" / "hooks"
sys.path.insert(0, str(_HOOKS_DIR))

guard_keywords = importlib.import_module("guard_keywords")

_HOOK_PATH = _HOOKS_DIR / "guard_keywords.py"
_REMOTE = "https://example.com/open/repo.git"
_TOKEN = "acmecorp"
_HIT = "contact acmecorp for details"
_CLEAN = "nothing to see here"


# ---------------------------------------------------------------------------
# helpers
# ---------------------------------------------------------------------------


def _env(tmp_path: Path, config: str = "") -> dict[str, str]:
    """Build a subprocess environment whose git config comes only from `config`."""
    home = tmp_path / "home"
    home.mkdir(exist_ok=True)
    global_config = tmp_path / "gitconfig"
    global_config.write_text(config, encoding="utf-8")
    env = {k: v for k, v in os.environ.items() if not k.startswith("GIT_")}
    env.update(
        {
            "HOME": str(home),
            "XDG_CONFIG_HOME": str(home / ".config"),
            "GIT_CONFIG_GLOBAL": str(global_config),
            "GIT_CONFIG_SYSTEM": "/dev/null",
            "GIT_CONFIG_NOSYSTEM": "1",
        }
    )
    return env


def _config(
    tokens: tuple[str, ...] = (),
    content_only: tuple[str, ...] = (),
    allowlist: tuple[str, ...] = (),
    *,
    old: bool = False,
) -> str:
    """Render a git config file body with the three koopa keys (`old` uses the old aliases)."""
    names = (
        ("restrictedTokens", "restrictedTokensContentOnly", "corpRemoteAllowlist")
        if old
        else ("keywords", "contentKeywords", "allowedRemotes")
    )
    lines = ["[koopa]"]
    lines += [f"\t{names[0]} = {t}" for t in tokens]
    lines += [f"\t{names[1]} = {t}" for t in content_only]
    lines += [f"\t{names[2]} = {t}" for t in allowlist]
    return "\n".join(lines) + "\n"


def _git(args: list[str], cwd: Path, env: dict[str, str]) -> None:
    subprocess.run(["git", *args], cwd=cwd, env=env, check=True, capture_output=True, text=True)


def _make_repo(tmp_path: Path, env: dict[str, str], remote: str | None = _REMOTE) -> Path:
    """Create a scratch repo with a public-looking origin, a few dirs, and an ignored dir."""
    repo = tmp_path / "repo"
    repo.mkdir()
    _git(["init", "-q"], repo, env)
    if remote is not None:
        _git(["remote", "add", "origin", remote], repo, env)
    (repo / ".gitignore").write_text("ignored/\n", encoding="utf-8")
    for name in ("src", "ignored", "acmecorp", "AcmeCorp-docs", "acmecorporation", "jdoe42"):
        (repo / name).mkdir()
    return repo


def _run(
    stdin: str, env: dict[str, str], cwd: Path | None = None
) -> subprocess.CompletedProcess[str]:
    """Run the real hook entry point, returning its result even for a nonzero exit."""
    try:
        return subprocess.run(
            [sys.executable, "-B", str(_HOOK_PATH)],
            input=stdin,
            capture_output=True,
            text=True,
            check=True,
            env=env,
            cwd=cwd,
        )
    except subprocess.CalledProcessError as error:
        return subprocess.CompletedProcess(error.cmd, error.returncode, error.stdout, error.stderr)


def _write(path: Path | str, content: str) -> str:
    """Claude Code `Write` payload."""
    return json.dumps({"tool_input": {"file_path": str(path), "content": content}})


def _edit(path: Path | str, new: str, old: str = "") -> str:
    """Claude Code `Edit` payload."""
    return json.dumps(
        {"tool_input": {"file_path": str(path), "new_string": new, "old_string": old}}
    )


def _patch(*files: tuple[str, str], cwd: Path | None = None) -> str:
    """Copilot `apply_patch` envelope that adds each `(path, content)` file."""
    lines = ["*** Begin Patch"]
    for path, content in files:
        lines.append(f"*** Add File: {path}")
        lines += [f"+{line}" for line in content.splitlines()]
    lines.append("*** End Patch")
    payload: dict[str, object] = {"tool_input": "\n".join(lines)}
    if cwd is not None:
        payload["cwd"] = str(cwd)
    return json.dumps(payload)


@pytest.fixture
def world(tmp_path: Path) -> tuple[Path, dict[str, str]]:
    """A scratch repo plus an environment configured with the placeholder token."""
    env = _env(tmp_path, _config(tokens=(_TOKEN,)))
    return _make_repo(tmp_path, env), env


# ---------------------------------------------------------------------------
# inert by default
# ---------------------------------------------------------------------------


def test_inert_with_no_config(tmp_path: Path) -> None:
    """With neither token key set the hook never blocks, even for token-like content."""
    env = _env(tmp_path)
    repo = _make_repo(tmp_path, env)
    result = _run(_write(repo / "src" / "a.txt", _HIT), env)
    assert result.returncode == 0
    assert result.stderr == ""


def test_allowlist_alone_does_not_activate(tmp_path: Path) -> None:
    """Only the allowlist key set: still inert."""
    env = _env(tmp_path, _config(allowlist=("example.com",)))
    repo = _make_repo(tmp_path, env)
    assert _run(_write(repo / "src" / "a.txt", _HIT), env).returncode == 0


# ---------------------------------------------------------------------------
# path and content matching
# ---------------------------------------------------------------------------


def test_content_match_blocks(world: tuple[Path, dict[str, str]]) -> None:
    """A restricted token in the new content blocks a write to a public-looking repo."""
    repo, env = world
    result = _run(_write(repo / "src" / "a.txt", _HIT), env)
    assert result.returncode == 2
    assert "configured keyword" in result.stderr
    assert "publishable" in result.stderr
    assert "(koopa.keywords)" in result.stderr
    assert "koopa.allowedRemotes" in result.stderr
    assert _TOKEN not in result.stderr.replace(str(repo), "")


def test_path_match_blocks(world: tuple[Path, dict[str, str]]) -> None:
    """A restricted token in the file path blocks even when the content is clean."""
    repo, env = world
    assert _run(_write(repo / "acmecorp" / "notes.txt", _CLEAN), env).returncode == 2


def test_path_match_is_case_insensitive(world: tuple[Path, dict[str, str]]) -> None:
    """The path check ignores case."""
    repo, env = world
    assert _run(_write(repo / "AcmeCorp-docs" / "notes.txt", _CLEAN), env).returncode == 2


def test_path_with_longer_word_is_not_a_match(world: tuple[Path, dict[str, str]]) -> None:
    """A directory named acmecorporation does not contain the token as a word."""
    repo, env = world
    assert _run(_write(repo / "acmecorporation" / "notes.txt", _CLEAN), env).returncode == 0


def test_content_only_token_ignored_in_path_but_matched_in_content(tmp_path: Path) -> None:
    """The content-only key is never checked in the path, always in the content."""
    env = _env(tmp_path, _config(content_only=("jdoe42",)))
    repo = _make_repo(tmp_path, env)
    assert _run(_write(repo / "jdoe42" / "x.txt", _CLEAN), env).returncode == 0
    result = _run(_write(repo / "src" / "x.txt", "home is /Users/jdoe42/work"), env)
    assert result.returncode == 2


def test_both_keys_combine_for_content(tmp_path: Path) -> None:
    """Content is checked against both lists together."""
    env = _env(tmp_path, _config(tokens=(_TOKEN,), content_only=("jdoe42",)))
    repo = _make_repo(tmp_path, env)
    assert _run(_write(repo / "src" / "a.txt", _HIT), env).returncode == 2
    assert _run(_write(repo / "src" / "b.txt", "user jdoe42 here"), env).returncode == 2
    assert _run(_write(repo / "src" / "c.txt", _CLEAN), env).returncode == 0


def test_multiple_tokens_in_one_key(tmp_path: Path) -> None:
    """Every value of a multi-valued key is an alternative."""
    env = _env(tmp_path, _config(tokens=(_TOKEN, "globex")))
    repo = _make_repo(tmp_path, env)
    assert _run(_write(repo / "src" / "a.txt", "see globex"), env).returncode == 2
    assert _run(_write(repo / "src" / "b.txt", _HIT), env).returncode == 2


@pytest.mark.parametrize(
    ("content", "blocked"),
    [
        pytest.param("acmecorporation", False, id="longer word after"),
        pytest.param("myacmecorp", False, id="letters before"),
        pytest.param("acmecorp2", False, id="digit after"),
        pytest.param("9acmecorp", False, id="digit before"),
        pytest.param("acmecorp_x", True, id="underscore after"),
        pytest.param("x_acmecorp", True, id="underscore before"),
        pytest.param("AcmeCorp", True, id="mixed case"),
        pytest.param("ACMECORP", True, id="upper case"),
        pytest.param("acmecorp", True, id="whole content"),
        pytest.param("(acmecorp)", True, id="punctuation"),
        pytest.param("a\nacmecorp\nb", True, id="own line"),
        pytest.param("acmecorp.example", True, id="dot after"),
        pytest.param("acme corp", False, id="split by space"),
    ],
)
def test_boundary_behavior(content: str, blocked: bool, world: tuple[Path, dict[str, str]]) -> None:
    """A token must not be adjacent to an ASCII letter or digit; underscore does not count."""
    repo, env = world
    expected = 2 if blocked else 0
    assert _run(_write(repo / "src" / "a.txt", content), env).returncode == expected


def test_pattern_is_a_regex_like_pre_commit(tmp_path: Path) -> None:
    """Values are extended regular expressions, as in the git pre-commit hook."""
    env = _env(tmp_path, _config(tokens=("acme(corp|inc)",)))
    repo = _make_repo(tmp_path, env)
    assert _run(_write(repo / "src" / "a.txt", "acmeinc"), env).returncode == 2
    assert _run(_write(repo / "src" / "b.txt", "acmellc"), env).returncode == 0


# ---------------------------------------------------------------------------
# only the new content counts
# ---------------------------------------------------------------------------


def test_old_string_is_ignored(world: tuple[Path, dict[str, str]]) -> None:
    """An edit that removes a token-bearing line is not blocked for the old text."""
    repo, env = world
    assert _run(_edit(repo / "src" / "a.txt", _CLEAN, old=_HIT), env).returncode == 0


def test_edit_introducing_a_token_blocks(world: tuple[Path, dict[str, str]]) -> None:
    """An edit whose new text carries a token is blocked."""
    repo, env = world
    assert _run(_edit(repo / "src" / "a.txt", _HIT, old=_CLEAN), env).returncode == 2


# ---------------------------------------------------------------------------
# publishability gate
# ---------------------------------------------------------------------------


def test_allowlisted_remote_allows(tmp_path: Path) -> None:
    """An origin URL containing an allowlist entry makes the tokens legitimate."""
    env = _env(tmp_path, _config(tokens=(_TOKEN,), allowlist=("example.com/open",)))
    repo = _make_repo(tmp_path, env)
    assert _run(_write(repo / "src" / "a.txt", _HIT), env).returncode == 0
    assert _run(_write(repo / "acmecorp" / "a.txt", _CLEAN), env).returncode == 0


def test_non_matching_allowlist_entry_still_blocks(tmp_path: Path) -> None:
    """An allowlist entry that is not in the origin URL does not exempt the repo."""
    env = _env(tmp_path, _config(tokens=(_TOKEN,), allowlist=("git.internal.invalid",)))
    repo = _make_repo(tmp_path, env)
    assert _run(_write(repo / "src" / "a.txt", _HIT), env).returncode == 2


def test_allowlist_match_is_case_sensitive_substring(tmp_path: Path) -> None:
    """Like the pre-commit hook, the entry must appear in the URL with the same case."""
    env = _env(tmp_path, _config(tokens=(_TOKEN,), allowlist=("EXAMPLE.COM",)))
    repo = _make_repo(tmp_path, env)
    assert _run(_write(repo / "src" / "a.txt", _HIT), env).returncode == 2


def test_gitignored_path_allows(world: tuple[Path, dict[str, str]]) -> None:
    """A path git ignores can never be published, so it is allowed."""
    repo, env = world
    assert _run(_write(repo / "ignored" / "a.txt", _HIT), env).returncode == 0


def test_non_repo_path_allows(tmp_path: Path) -> None:
    """A directory outside any git work tree is allowed."""
    env = _env(tmp_path, _config(tokens=(_TOKEN,)))
    plain = tmp_path / "plain"
    plain.mkdir()
    assert _run(_write(plain / "a.txt", _HIT), env).returncode == 0


def test_missing_directory_allows(world: tuple[Path, dict[str, str]]) -> None:
    """A target whose directory does not exist yet is allowed."""
    repo, env = world
    assert _run(_write(repo / "not-yet" / "a.txt", _HIT), env).returncode == 0


def test_relative_path_allows(world: tuple[Path, dict[str, str]]) -> None:
    """A relative path with no payload cwd is allowed even from inside the repo."""
    repo, env = world
    assert _run(_write("src/a.txt", _HIT), env, cwd=repo).returncode == 0


def test_repo_without_origin_blocks(tmp_path: Path) -> None:
    """No origin remote means no allowlist match, so the write is blocked (like pre-commit)."""
    env = _env(tmp_path, _config(tokens=(_TOKEN,), allowlist=("example.com",)))
    repo = _make_repo(tmp_path, env, remote=None)
    assert _run(_write(repo / "src" / "a.txt", _HIT), env).returncode == 2


def test_clean_write_is_allowed(world: tuple[Path, dict[str, str]]) -> None:
    """A clean write is never blocked regardless of publishability."""
    repo, env = world
    assert _run(_write(repo / "src" / "a.txt", _CLEAN), env).returncode == 0


# ---------------------------------------------------------------------------
# tool shapes
# ---------------------------------------------------------------------------


def test_copilot_create_shape(world: tuple[Path, dict[str, str]]) -> None:
    """Copilot `create` sends `path` and `file_text`."""
    repo, env = world
    payload = json.dumps({"tool_input": {"path": str(repo / "src" / "a.txt"), "file_text": _HIT}})
    assert _run(payload, env).returncode == 2
    clean = json.dumps({"tool_input": {"path": str(repo / "src" / "a.txt"), "file_text": _CLEAN}})
    assert _run(clean, env).returncode == 0


def test_copilot_edit_shape(world: tuple[Path, dict[str, str]]) -> None:
    """Copilot `edit` sends `path`, `old_str` and `new_str`; only `new_str` counts."""
    repo, env = world
    path = str(repo / "src" / "a.txt")
    hit = json.dumps({"tool_input": {"path": path, "old_str": _CLEAN, "new_str": _HIT}})
    keep = json.dumps({"tool_input": {"path": path, "old_str": _HIT, "new_str": _CLEAN}})
    assert _run(hit, env).returncode == 2
    assert _run(keep, env).returncode == 0


def test_copilot_batched_tool_calls_shape(world: tuple[Path, dict[str, str]]) -> None:
    """Copilot's batched `toolCalls[]` shape is read too."""
    repo, env = world
    path = str(repo / "src" / "a.txt")
    payload = json.dumps(
        {
            "toolCalls": [
                {"args": {"path": path, "file_text": _CLEAN}},
                {"args": {"path": path, "file_text": _HIT}},
            ]
        }
    )
    assert _run(payload, env).returncode == 2


def test_apply_patch_only_second_file_hits(world: tuple[Path, dict[str, str]]) -> None:
    """Each file in a patch envelope is judged separately; one hit blocks the call."""
    repo, env = world
    both = _patch((str(repo / "src" / "a.txt"), _CLEAN), (str(repo / "src" / "b.txt"), _HIT))
    assert _run(both, env).returncode == 2
    clean = _patch((str(repo / "src" / "a.txt"), _CLEAN), (str(repo / "src" / "b.txt"), _CLEAN))
    assert _run(clean, env).returncode == 0


def test_apply_patch_judges_each_file_under_its_own_path(
    world: tuple[Path, dict[str, str]], tmp_path: Path
) -> None:
    """A hit in an ignored or non-repo file does not block; a later repo hit does."""
    repo, env = world
    plain = tmp_path / "plain"
    plain.mkdir()
    allowed_only = _patch((str(repo / "ignored" / "a.txt"), _HIT), (str(plain / "b.txt"), _HIT))
    assert _run(allowed_only, env).returncode == 0
    mixed = _patch((str(plain / "b.txt"), _HIT), (str(repo / "src" / "c.txt"), _HIT))
    assert _run(mixed, env).returncode == 2


def test_apply_patch_relative_paths_resolve_against_payload_cwd(
    world: tuple[Path, dict[str, str]],
) -> None:
    """Relative patch paths are resolved against the payload `cwd` before the gate runs."""
    repo, env = world
    assert _run(_patch(("src/a.txt", _HIT), cwd=repo), env).returncode == 2
    assert _run(_patch(("ignored/a.txt", _HIT), cwd=repo), env).returncode == 0


def test_apply_patch_delete_is_never_blocked(world: tuple[Path, dict[str, str]]) -> None:
    """Deleting a file whose path carries a token is the cleanup path, so it passes."""
    repo, env = world
    envelope = f"*** Begin Patch\n*** Delete File: {repo / 'acmecorp' / 'old.txt'}\n*** End Patch"
    assert _run(json.dumps({"tool_input": envelope}), env).returncode == 0


# ---------------------------------------------------------------------------
# fail-open behavior
# ---------------------------------------------------------------------------


@pytest.mark.parametrize("stdin", ["", "   \n", "{not json", "[1, 2]", "{}", '{"tool_input": "x"}'])
def test_entry_fails_open_on_empty_or_malformed_stdin(
    stdin: str, world: tuple[Path, dict[str, str]]
) -> None:
    """Empty, malformed, or unrecognized input exits 0."""
    _, env = world
    assert _run(stdin, env).returncode == 0


def test_invalid_pattern_is_skipped_with_one_warning(tmp_path: Path) -> None:
    """A pattern that does not compile is skipped; the valid one still works."""
    env = _env(tmp_path, _config(tokens=("(unclosed", _TOKEN)))
    repo = _make_repo(tmp_path, env)
    hit = _run(_write(repo / "src" / "a.txt", _HIT), env)
    assert hit.returncode == 2
    clean = _run(_write(repo / "src" / "b.txt", _CLEAN), env)
    assert clean.returncode == 0
    warnings = [ln for ln in clean.stderr.splitlines() if "invalid pattern" in ln]
    assert len(warnings) == 1
    assert "(unclosed" not in clean.stderr


def test_only_invalid_patterns_never_crash(tmp_path: Path) -> None:
    """With every pattern invalid the hook warns and allows."""
    env = _env(tmp_path, _config(tokens=("(unclosed",), content_only=("[bad",)))
    repo = _make_repo(tmp_path, env)
    result = _run(_write(repo / "src" / "a.txt", _HIT), env)
    assert result.returncode == 0
    assert "Traceback" not in result.stderr
    assert len([ln for ln in result.stderr.splitlines() if "invalid pattern" in ln]) == 2


def test_internal_error_fails_open(
    monkeypatch: pytest.MonkeyPatch, capsys: pytest.CaptureFixture[str]
) -> None:
    """An unexpected exception exits 0 with one line on stderr."""
    hook_adapter = importlib.import_module("hook_adapter")

    def boom(raw: str) -> list[object]:
        raise RuntimeError("synthetic failure")

    monkeypatch.setattr(hook_adapter, "targets_or_skip", boom)
    monkeypatch.setattr(sys, "stdin", io.StringIO("{}"))
    with pytest.raises(SystemExit) as exit_info:
        runpy.run_path(str(_HOOK_PATH), run_name="__main__")
    assert exit_info.value.code == 0
    err = capsys.readouterr().err
    assert len(err.strip().splitlines()) == 1
    assert "RuntimeError" in err


def test_git_failures_allow(monkeypatch: pytest.MonkeyPatch, tmp_path: Path) -> None:
    """A git timeout or a missing git binary reads as no config and as not publishable."""

    def timeout(*args: object, **kwargs: object) -> None:
        raise subprocess.TimeoutExpired(cmd="git", timeout=5)

    def missing(*args: object, **kwargs: object) -> None:
        raise FileNotFoundError("git")

    for failure in (timeout, missing):
        monkeypatch.setattr(guard_keywords.subprocess, "run", failure)
        assert guard_keywords._config_values("koopa.keywords") == []
        assert guard_keywords._is_publishable(str(tmp_path / "a.txt")) is False


def test_git_calls_use_a_five_second_timeout(
    monkeypatch: pytest.MonkeyPatch, tmp_path: Path
) -> None:
    """Every git invocation passes timeout=5 and check=True."""
    seen: list[dict[str, object]] = []

    def fake_run(cmd: list[str], **kwargs: object) -> subprocess.CompletedProcess[str]:
        seen.append(kwargs)
        return subprocess.CompletedProcess(cmd, 0, stdout="true\n", stderr="")

    monkeypatch.setattr(guard_keywords.subprocess, "run", fake_run)
    guard_keywords._config_values("koopa.keywords")
    guard_keywords._is_publishable(str(tmp_path / "a.txt"))
    assert len(seen) >= 4
    assert all(kw["timeout"] == 5 and kw["check"] is True for kw in seen)


# ---------------------------------------------------------------------------
# deprecated key aliases (restrictedTokens and friends)
# ---------------------------------------------------------------------------


def test_old_keyword_key_alone_blocks(tmp_path: Path) -> None:
    """The deprecated `koopa.restrictedTokens` alone still activates and blocks."""
    env = _env(tmp_path, _config(tokens=(_TOKEN,), old=True))
    repo = _make_repo(tmp_path, env)
    assert _run(_write(repo / "src" / "a.txt", _HIT), env).returncode == 2
    assert _run(_write(repo / "acmecorp" / "a.txt", _CLEAN), env).returncode == 2


def test_old_content_only_key_alone_blocks(tmp_path: Path) -> None:
    """The deprecated content-only alias matches content but not the path."""
    env = _env(tmp_path, _config(content_only=("jdoe42",), old=True))
    repo = _make_repo(tmp_path, env)
    assert _run(_write(repo / "jdoe42" / "a.txt", _CLEAN), env).returncode == 0
    assert _run(_write(repo / "src" / "a.txt", "by jdoe42 here"), env).returncode == 2


def test_old_allowlist_key_alone_allows(tmp_path: Path) -> None:
    """The deprecated `koopa.corpRemoteAllowlist` still exempts a matching origin."""
    env = _env(tmp_path, _config(tokens=(_TOKEN,), allowlist=("example.com/open",), old=True))
    repo = _make_repo(tmp_path, env)
    assert _run(_write(repo / "src" / "a.txt", _HIT), env).returncode == 0


def test_new_and_old_keys_are_merged(tmp_path: Path) -> None:
    """Keywords and allowlist entries from the new and old keys both apply."""
    config = _config(tokens=(_TOKEN,), allowlist=("git.internal.invalid",)) + _config(
        tokens=("globex",), content_only=("jdoe42",), allowlist=("example.com/open",), old=True
    )
    env = _env(tmp_path, config)
    repo = _make_repo(tmp_path, env, remote="https://example.org/other/repo.git")
    assert _run(_write(repo / "src" / "a.txt", _HIT), env).returncode == 2
    assert _run(_write(repo / "src" / "a.txt", "see globex"), env).returncode == 2
    assert _run(_write(repo / "src" / "a.txt", "by jdoe42 here"), env).returncode == 2
    allowed = tmp_path / "allowed"
    allowed.mkdir()
    env2 = _env(allowed, config)
    repo2 = _make_repo(allowed, env2)
    assert _run(_write(repo2 / "src" / "a.txt", _HIT), env2).returncode == 0
    assert _run(_write(repo2 / "src" / "a.txt", "see globex"), env2).returncode == 0


def test_merge_helper_dedupes_and_preserves_order(
    monkeypatch: pytest.MonkeyPatch, tmp_path: Path
) -> None:
    """The same value in both keys is applied once; new-key values come first."""
    env = _env(
        tmp_path,
        _config(tokens=(_TOKEN, "globex")) + _config(tokens=("globex", "jdoe42"), old=True),
    )
    for name, value in env.items():
        monkeypatch.setenv(name, value)
    merged = guard_keywords._merged_values("koopa.keywords", "koopa.restrictedTokens")
    assert merged == [_TOKEN, "globex", "jdoe42"]


def test_block_message_names_new_keys(world: tuple[Path, dict[str, str]]) -> None:
    """The block message names the new keyword and allowed-remotes keys, not the old ones."""
    repo, env = world
    result = _run(_write(repo / "src" / "a.txt", _HIT), env)
    assert result.returncode == 2
    assert "contains a configured keyword (koopa.keywords)" in result.stderr
    assert "koopa.allowedRemotes" in result.stderr
    assert "restrictedTokens" not in result.stderr
    assert "corpRemoteAllowlist" not in result.stderr
