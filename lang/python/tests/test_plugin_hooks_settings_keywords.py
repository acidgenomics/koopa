"""Tests for the koopa plugin settings keyword guard (guard_settings_keywords.py).

The hook is Claude Code only. On `SessionStart` and `Stop` it scans
`$CLAUDE_PROJECT_DIR/.claude/settings.json` for a configured keyword (git config keys
`koopa.keywords`, `koopa.contentKeywords`, `koopa.allowedRemotes`) in a publishable repository.
It does nothing unless `CLAUDE_PROJECT_DIR` is set.

Safety: every keyword in this file is a made-up placeholder (`acmecorp`). Each test isolates git
configuration with `GIT_CONFIG_GLOBAL` pointing at a file under `tmp_path`,
`GIT_CONFIG_SYSTEM=/dev/null`, and a `HOME` under `tmp_path`. Git runs only inside `tmp_path`
repositories. The hook only reads the settings file.
"""

import json
import os
import subprocess
import sys
from pathlib import Path

import pytest
from koopa.prefix import koopa_prefix

_HOOK = Path(koopa_prefix()) / "plugins" / "koopa" / "hooks" / "guard_settings_keywords.py"
_REMOTE = "https://example.com/open/repo.git"
_LEAKY = '{\n  "permissions": {\n    "allow": ["Bash(acmecorp-tool:*)"]\n  }\n}\n'
_CLEAN = '{\n  "permissions": {\n    "allow": ["Bash(ls:*)"]\n  }\n}\n'
_CONFIG = "[koopa]\n\tkeywords = acmecorp\n"


def _env(tmp_path: Path, config: str = _CONFIG, project: Path | None = None) -> dict[str, str]:
    """Build an isolated environment; `project` sets CLAUDE_PROJECT_DIR when given."""
    home = tmp_path / "home"
    home.mkdir(parents=True, exist_ok=True)
    global_config = tmp_path / "gitconfig"
    global_config.write_text(config, encoding="utf-8")
    env = {
        k: v
        for k, v in os.environ.items()
        if not k.startswith("GIT_") and k != "CLAUDE_PROJECT_DIR"
    }
    env.update(
        {
            "HOME": str(home),
            "XDG_CONFIG_HOME": str(home / ".config"),
            "GIT_CONFIG_GLOBAL": str(global_config),
            "GIT_CONFIG_SYSTEM": "/dev/null",
            "GIT_CONFIG_NOSYSTEM": "1",
            "PYTHONDONTWRITEBYTECODE": "1",
        }
    )
    if project is not None:
        env["CLAUDE_PROJECT_DIR"] = str(project)
    return env


def _git(args: list[str], cwd: Path, env: dict[str, str]) -> None:
    subprocess.run(["git", *args], cwd=cwd, env=env, check=True, capture_output=True, text=True)


def _project(
    tmp_path: Path, settings: str | None = _LEAKY, remote: str | None = _REMOTE
) -> tuple[Path, dict[str, str]]:
    """Create a scratch repo with a settings file and return (repo, env with the gate open)."""
    repo = tmp_path / "repo"
    (repo / ".claude").mkdir(parents=True)
    env = _env(tmp_path, project=repo)
    _git(["init", "-q"], repo, env)
    if remote is not None:
        _git(["remote", "add", "origin", remote], repo, env)
    if settings is not None:
        (repo / ".claude" / "settings.json").write_text(settings, encoding="utf-8")
    return repo, env


def _run(
    stdin: str, env: dict[str, str], cwd: Path | None = None
) -> subprocess.CompletedProcess[str]:
    """Run the real hook entry; a nonzero exit is returned, not raised."""
    try:
        return subprocess.run(
            [sys.executable, "-B", str(_HOOK)],
            input=stdin,
            capture_output=True,
            text=True,
            check=True,
            env=env,
            cwd=cwd,
        )
    except subprocess.CalledProcessError as error:
        return subprocess.CompletedProcess(error.cmd, error.returncode, error.stdout, error.stderr)


def _event(name: str, **extra: object) -> str:
    """A Claude Code hook payload for an event."""
    return json.dumps({"hook_event_name": name, **extra})


def test_session_start_reports_through_additional_context(tmp_path: Path) -> None:
    """SessionStart prints additionalContext with the line number and exits 0."""
    repo, env = _project(tmp_path)
    result = _run(_event("SessionStart"), env)
    assert result.returncode == 0
    assert result.stderr == ""
    output = json.loads(result.stdout)["hookSpecificOutput"]
    assert output["hookEventName"] == "SessionStart"
    context = output["additionalContext"]
    assert str(repo / ".claude" / "settings.json") in context
    assert "line(s): 3" in context
    assert "settings.local.json" in context
    assert "acmecorp" not in context


def test_stop_blocks_with_exit_2_and_the_message_on_stderr(tmp_path: Path) -> None:
    """Stop exits 2 with the reason on stderr and nothing on stdout."""
    _, env = _project(tmp_path)
    result = _run(_event("Stop", stop_hook_active=False), env)
    assert result.returncode == 2
    assert result.stdout == ""
    assert "line(s): 3" in result.stderr
    assert "acmecorp" not in result.stderr


@pytest.mark.parametrize("flag", [True, "true"])
def test_stop_hook_active_never_loops(flag: object, tmp_path: Path) -> None:
    """When Claude is already continuing because of a stop hook, Stop exits 0 silently."""
    _, env = _project(tmp_path)
    result = _run(_event("Stop", stop_hook_active=flag), env)
    assert (result.returncode, result.stdout, result.stderr) == (0, "", "")


def test_stop_without_the_flag_blocks(tmp_path: Path) -> None:
    """A Stop payload that omits stop_hook_active is treated as not active."""
    _, env = _project(tmp_path)
    assert _run(_event("Stop"), env).returncode == 2


def test_unknown_event_is_reported_as_session_start(tmp_path: Path) -> None:
    """Any event other than Stop takes the non-blocking context path."""
    _, env = _project(tmp_path)
    result = _run(json.dumps({"cwd": str(tmp_path)}), env)
    assert result.returncode == 0
    assert "additionalContext" in result.stdout


@pytest.mark.parametrize("event", ["SessionStart", "Stop"])
def test_without_claude_project_dir_the_hook_does_nothing(event: str, tmp_path: Path) -> None:
    """The self-gate: no CLAUDE_PROJECT_DIR means not a Claude Code session, so no-op."""
    repo, env = _project(tmp_path)
    del env["CLAUDE_PROJECT_DIR"]
    payload = _event(event, cwd=str(repo))
    result = _run(payload, env, cwd=repo)  # the leaky file is in the cwd and the payload cwd
    assert (result.returncode, result.stdout, result.stderr) == (0, "", "")


def test_an_empty_claude_project_dir_counts_as_unset(tmp_path: Path) -> None:
    """An empty variable does not open the gate."""
    repo, env = _project(tmp_path)
    env["CLAUDE_PROJECT_DIR"] = ""
    assert _run(_event("Stop"), env, cwd=repo).returncode == 0


def test_a_clean_settings_file_passes(tmp_path: Path) -> None:
    """No keyword in the file means no output and exit 0."""
    _, env = _project(tmp_path, settings=_CLEAN)
    result = _run(_event("Stop"), env)
    assert (result.returncode, result.stdout, result.stderr) == (0, "", "")


def test_a_missing_settings_file_passes(tmp_path: Path) -> None:
    """No `.claude/settings.json` is not an error."""
    _, env = _project(tmp_path, settings=None)
    assert _run(_event("Stop"), env).returncode == 0


def test_inert_with_no_keywords_configured(tmp_path: Path) -> None:
    """The plugin ships no keywords: an empty config never reports."""
    repo, _ = _project(tmp_path)
    env = _env(tmp_path, config="", project=repo)
    assert _run(_event("Stop"), env).returncode == 0


def test_allowlist_alone_does_not_activate(tmp_path: Path) -> None:
    """`koopa.allowedRemotes` without any keyword is inert."""
    repo, _ = _project(tmp_path)
    env = _env(tmp_path, config="[koopa]\n\tallowedRemotes = example.com\n", project=repo)
    assert _run(_event("Stop"), env).returncode == 0


def test_content_keyword_key_is_scanned(tmp_path: Path) -> None:
    """`koopa.contentKeywords` is scanned too."""
    repo, _ = _project(tmp_path)
    env = _env(tmp_path, config="[koopa]\n\tcontentKeywords = acmecorp\n", project=repo)
    assert _run(_event("Stop"), env).returncode == 2


def test_deprecated_alias_keys_are_read(tmp_path: Path) -> None:
    """The old `restrictedTokens` key still arms the hook."""
    repo, _ = _project(tmp_path)
    env = _env(tmp_path, config="[koopa]\n\trestrictedTokens = acmecorp\n", project=repo)
    assert _run(_event("Stop"), env).returncode == 2


def test_allowed_remote_exempts_the_repo(tmp_path: Path) -> None:
    """A remote on the allowlist is a place where the keyword is legitimate."""
    repo, _ = _project(tmp_path)
    config = _CONFIG + "\tallowedRemotes = example.com/open\n"
    assert _run(_event("Stop"), _env(tmp_path, config, repo)).returncode == 0


def test_deprecated_allowlist_alias_is_read(tmp_path: Path) -> None:
    """The old `corpRemoteAllowlist` key still exempts the repo."""
    repo, _ = _project(tmp_path)
    config = _CONFIG + "[koopa]\n\tcorpRemoteAllowlist = example.com\n"
    assert _run(_event("Stop"), _env(tmp_path, config, repo)).returncode == 0


def test_a_non_matching_allowlist_entry_still_reports(tmp_path: Path) -> None:
    """An allowlist entry that is not in the origin URL exempts nothing."""
    repo, _ = _project(tmp_path)
    config = _CONFIG + "\tallowedRemotes = other.example.org\n"
    assert _run(_event("Stop"), _env(tmp_path, config, repo)).returncode == 2


def test_a_gitignored_settings_file_passes(tmp_path: Path) -> None:
    """A file the repo ignores is never published, so it is not reported."""
    repo, env = _project(tmp_path)
    (repo / ".gitignore").write_text(".claude/settings.json\n", encoding="utf-8")
    assert _run(_event("Stop"), env).returncode == 0


def test_a_project_outside_any_repo_passes(tmp_path: Path) -> None:
    """Not a git work tree: not publishable, so no report."""
    project = tmp_path / "plain"
    (project / ".claude").mkdir(parents=True)
    (project / ".claude" / "settings.json").write_text(_LEAKY, encoding="utf-8")
    assert _run(_event("Stop"), _env(tmp_path, project=project)).returncode == 0


def test_a_repo_without_origin_still_reports(tmp_path: Path) -> None:
    """With no remote there is nothing to allowlist, so the keyword is reported."""
    _, env = _project(tmp_path, remote=None)
    assert _run(_event("Stop"), env).returncode == 2


@pytest.mark.parametrize(
    ("text", "reported"),
    [
        ('"acmecorp"', True),
        ("ACMECORP", True),
        ("x acmecorp-tool", True),
        ("acmecorporation", False),
        ("myacmecorp", False),
        ("acmecorp2", False),
    ],
)
def test_boundary_rule(text: str, reported: bool, tmp_path: Path) -> None:
    """A match must not touch an ASCII letter or digit on either side; case is ignored."""
    _, env = _project(tmp_path, settings=f"{{}}\n{text}\n")
    assert (_run(_event("Stop"), env).returncode == 2) is reported


def test_every_matching_line_is_listed(tmp_path: Path) -> None:
    """Line numbers are 1-based and comma separated."""
    _, env = _project(tmp_path, settings="acmecorp\nok\nacmecorp\n")
    assert "line(s): 1,3" in _run(_event("Stop"), env).stderr


def test_an_invalid_pattern_is_skipped_with_one_warning(tmp_path: Path) -> None:
    """A pattern that does not compile is dropped; the valid one still works."""
    repo, _ = _project(tmp_path)
    env = _env(tmp_path, config="[koopa]\n\tkeywords = (\n\tkeywords = acmecorp\n", project=repo)
    result = _run(_event("Stop"), env)
    assert result.returncode == 2
    assert result.stderr.count("skipping an invalid pattern") == 1


def test_only_invalid_patterns_never_crash(tmp_path: Path) -> None:
    """When nothing compiles the hook has no matcher and exits 0."""
    repo, _ = _project(tmp_path)
    env = _env(tmp_path, config="[koopa]\n\tkeywords = (\n", project=repo)
    assert _run(_event("Stop"), env).returncode == 0


def test_an_unreadable_settings_file_is_handled(tmp_path: Path) -> None:
    """Bytes that are not UTF-8 are decoded with replacement, not a crash."""
    repo, env = _project(tmp_path, settings=None)
    (repo / ".claude" / "settings.json").write_bytes(b"\xff\xfe acmecorp\n")
    assert _run(_event("Stop"), env).returncode == 2


@pytest.mark.parametrize("stdin", ["", "  \n", "not json", "[]", "3"])
def test_empty_or_malformed_stdin_exits_zero(stdin: str, tmp_path: Path) -> None:
    """No JSON object on stdin means no opinion, even with the gate open and a leak present."""
    _, env = _project(tmp_path)
    result = _run(stdin, env)
    assert (result.returncode, result.stdout, result.stderr) == (0, "", "")


def test_git_missing_fails_open(tmp_path: Path) -> None:
    """With git absent from PATH no config can be read, so nothing is reported."""
    _, env = _project(tmp_path)
    env["PATH"] = str(tmp_path / "empty-bin")
    result = _run(_event("Stop"), env)
    assert (result.returncode, result.stdout) == (0, "")


def test_internal_error_fails_open(tmp_path: Path) -> None:
    """An unexpected exception exits 0 with one line on stderr."""
    repo, env = _project(tmp_path)
    runner = tmp_path / "run_hook.py"
    runner.write_text(
        "import runpy\n"
        "import guard_keywords\n"
        "def boom(*args):\n"
        "    raise RuntimeError('x')\n"
        "guard_keywords._merged_values = boom\n"
        f"runpy.run_path({str(_HOOK)!r}, run_name='__main__')\n",
        encoding="utf-8",
    )
    env["PYTHONPATH"] = str(_HOOK.parent)
    result = subprocess.run(
        [sys.executable, "-B", str(runner)],
        input=_event("Stop"),
        capture_output=True,
        text=True,
        check=True,
        env=env,
    )
    assert result.returncode == 0
    assert "RuntimeError" in result.stderr
    assert str(repo) not in result.stderr
