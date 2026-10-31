"""Tests for the koopa plugin's git hooks (plugins/koopa/hooks).

Covers ``guard_git_scan.py``, ``block_destructive_git.py`` and
``audit_secrets_before_push.py``. The hooks are stand-alone Python that ships inside
the plugin, so they are loaded here by path rather than imported from the koopa
package. Subprocess tests run the real hook entries with a Claude ``tool_input``
payload and a Copilot ``toolCalls[]`` batch.

Safety: every test that runs git does so inside a ``tmp_path`` repository with an
explicit ``cwd=``. An autouse fixture points ``CLAUDE_PROJECT_DIR`` at that scratch
repository, so the scanner never inspects the koopa repository or the process cwd.

Two lists drive the scanner tests. BLOCKED must stay blocked (a regression reopens a
guard). ALLOWED must pass (a regression brings back the false positives).
"""

import importlib
import io
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

_scan = importlib.import_module("guard_git_scan")
_shell = importlib.import_module("shell_command_scan")
destructive = importlib.import_module("block_destructive_git")
secrets = importlib.import_module("audit_secrets_before_push")

_DESTRUCTIVE = _HOOKS_DIR / "block_destructive_git.py"
_SECRETS = _HOOKS_DIR / "audit_secrets_before_push.py"


def _git(repo: Path, *args: str) -> None:
    """Run git inside a scratch repository without user hooks or commit signing."""
    subprocess.run(
        [
            "git",
            "-c",
            "user.email=test@example.com",
            "-c",
            "user.name=Test",
            "-c",
            "core.hooksPath=/dev/null",
            "-c",
            "commit.gpgSign=false",
            *args,
        ],
        cwd=repo,
        check=True,
        capture_output=True,
        text=True,
    )


def _make_repo_with_remote(base: Path) -> Path:
    """A local repo with a pushed ``main`` and an upstream tracking branch."""
    base.mkdir(parents=True, exist_ok=True)
    remote = base / "remote.git"
    subprocess.run(
        ["git", "init", "-q", "--bare", str(remote)], cwd=base, check=True, capture_output=True
    )
    repo = base / "repo"
    repo.mkdir()
    _git(repo, "init", "-q", "-b", "main")
    _git(repo, "remote", "add", "origin", str(remote))
    (repo / "readme.md").write_text("hello\n")
    _git(repo, "add", "readme.md")
    _git(repo, "commit", "-q", "-m", "init")
    _git(repo, "push", "-q", "-u", "origin", "main")
    return repo


def _commit_file(repo: Path, name: str) -> None:
    """Commit a file without pushing. ``-f`` beats a global gitignore for ``.env``."""
    (repo / name).write_text("SECRET=abc\n")
    _git(repo, "add", "-f", name)
    _git(repo, "commit", "-q", "-m", f"add {name}")


@pytest.fixture(autouse=True)
def project(tmp_path: Path, monkeypatch: pytest.MonkeyPatch) -> Path:
    """A scratch repository that every in-process scanner call treats as the project."""
    repo = _make_repo_with_remote(tmp_path / "project")
    monkeypatch.setenv("CLAUDE_PROJECT_DIR", str(repo))
    monkeypatch.chdir(tmp_path)
    return repo


def _run(
    entry: Path,
    stdin: str,
    cwd: Path,
    project_dir: Path | None = None,
    home: Path | None = None,
) -> tuple[int, str]:
    """Run a real hook entry; return ``(exit code, stderr)``."""
    env = {**os.environ, "PYTHONDONTWRITEBYTECODE": "1"}
    env.pop("CLAUDE_PROJECT_DIR", None)
    if project_dir is not None:
        env["CLAUDE_PROJECT_DIR"] = str(project_dir)
    if home is not None:
        env["HOME"] = str(home)
    try:
        proc = subprocess.run(
            [sys.executable, "-B", "-E", "-s", str(entry)],
            input=stdin,
            capture_output=True,
            text=True,
            check=True,
            env=env,
            cwd=cwd,
        )
    except subprocess.CalledProcessError as error:
        return error.returncode, error.stderr
    return proc.returncode, proc.stderr


def _claude(command: str, **extra: str) -> str:
    """Build a Claude Code PreToolUse payload."""
    return json.dumps({"tool_name": "Bash", "tool_input": {"command": command}, **extra})


def _copilot(*commands: str) -> str:
    """Build a Copilot CLI batched ``toolCalls[]`` payload."""
    return json.dumps({"toolCalls": [{"args": {"command": c}} for c in commands]})


# ---------------------------------------------------------------------------
# guard_git_scan.py: destructive
# ---------------------------------------------------------------------------

BLOCKED = [
    pytest.param("git reset --hard", id="reset hard"),
    pytest.param("git reset --hard HEAD~1", id="reset hard to commit"),
    pytest.param("git clean -fd", id="clean fd"),
    pytest.param("git clean -fdx", id="clean fdx"),
    pytest.param("git clean -f -d", id="clean split flags"),
    pytest.param("git clean --force -d", id="clean long force"),
    pytest.param("git push --force", id="push force"),
    pytest.param("git push -f origin feature", id="push -f"),
    pytest.param("git push --force-with-lease origin feature", id="push force with lease"),
    pytest.param("git push origin +feature", id="push plus refspec"),
    pytest.param("git rm -rf dir", id="rm rf"),
    pytest.param("git rm -r -f dir", id="rm split flags"),
    pytest.param("git checkout -- .", id="checkout dot"),
    pytest.param("git branch -D old", id="branch D"),
    pytest.param("git push origin main", id="push main"),
    pytest.param("git push origin master", id="push master"),
    pytest.param("git push origin HEAD:main", id="push HEAD to main"),
    pytest.param("git -C . push origin main", id="git -C dot push main"),
    pytest.param("cd . && git push origin main", id="cd dot then push main"),
    pytest.param('cd "$(pwd)" && git push origin main', id="cd quoted pwd then push main"),
    pytest.param("sudo git reset --hard", id="behind sudo"),
    pytest.param("env FOO=1 git reset --hard", id="behind env"),
    pytest.param("echo ok && git reset --hard", id="after and"),
    pytest.param("bash -c 'git reset --hard'", id="inside bash -c"),
    pytest.param("ssh host 'git branch -D old'", id="inside ssh"),
    pytest.param("echo $(git reset --hard)", id="inside substitution"),
    pytest.param("git add -A", id="add all"),
    pytest.param("git add --all", id="add all long"),
    pytest.param("git add -u", id="add update"),
    pytest.param("git add .", id="add dot"),
    pytest.param("git add -- .", id="add dot after separator"),
    pytest.param("git add :/", id="add repo root"),
    pytest.param("git commit -a -m wip", id="commit all"),
    pytest.param("git commit -am wip", id="commit all bundled"),
    pytest.param("git stash", id="bare stash"),
    pytest.param("git stash -u", id="stash untracked whole tree"),
    pytest.param("git stash push -m tag", id="stash push no pathspec"),
    pytest.param("git stash save wip", id="stash save"),
    pytest.param("git stash pop", id="stash pop"),
    pytest.param("git stash drop", id="stash drop"),
    pytest.param("git stash clear", id="stash clear"),
    pytest.param("git restore .", id="restore dot"),
    pytest.param("git restore --staged :/", id="restore repo root"),
    pytest.param("git checkout .", id="checkout dot no separator"),
    pytest.param("git worktree remove ../other", id="worktree remove"),
    pytest.param("git worktree prune", id="worktree prune"),
    pytest.param("git -c core.pager=cat add -A", id="add all behind -c"),
    pytest.param("git push --all", id="push all"),
    pytest.param("git push origin --branches", id="push branches"),
    pytest.param("git push origin --mirror", id="push mirror"),
    pytest.param("git push origin :", id="push matching"),
    pytest.param("git push origin 'refs/heads/*:refs/heads/*'", id="push glob"),
    pytest.param("git push origin refs/heads/main", id="push full main ref"),
]

ALLOWED = [
    pytest.param("git status", id="status"),
    pytest.param("git log --oneline", id="log"),
    pytest.param("git reset --soft HEAD~1", id="reset soft"),
    pytest.param("git clean -n", id="clean dry run"),
    pytest.param("git clean -nd", id="clean dry run dirs"),
    pytest.param("git branch -d merged", id="branch d"),
    pytest.param("git checkout main", id="checkout branch"),
    pytest.param("git checkout -- file.txt", id="checkout one file"),
    pytest.param("git push origin feature", id="push feature"),
    pytest.param("git push -u origin feature", id="push set upstream"),
    pytest.param("git rm file.txt", id="rm one file"),
    pytest.param("git rm -r dir", id="rm recursive"),
    pytest.param("grep -rn 'reset --hard' docs", id="grep pattern"),
    pytest.param('git commit -m "avoid reset --hard"', id="commit message"),
    pytest.param("echo 'git push --force'", id="echo"),
    pytest.param('grep -n "rm -rf" some_file.py', id="grep for rm -rf"),
    pytest.param("rm -rf /nonexistent/scratch", id="plain shell rm -rf"),
    pytest.param(
        "python3 -I - <<'EOF'\nprint('never run git push origin main')\nEOF",
        id="python heredoc text",
    ),
    pytest.param("git add src/x.py", id="add named file"),
    pytest.param("git add -- src/x.py docs/y.md", id="add named files"),
    pytest.param("git commit --amend --no-edit", id="commit amend"),
    pytest.param('git commit -m "add a thing"', id="commit message with a"),
    pytest.param("git stash push -u -- src/x.py", id="stash named path"),
    pytest.param("git stash list", id="stash list"),
    pytest.param("git stash show -p", id="stash show"),
    pytest.param("git stash apply 'stash@{0}'", id="stash apply"),
    pytest.param("git restore src/x.py", id="restore one file"),
    pytest.param("git worktree list", id="worktree list"),
    pytest.param("git worktree add ../wt feature", id="worktree add"),
    pytest.param("git push", id="push to upstream"),
    pytest.param("git push upstream main", id="push main to non-origin remote"),
    pytest.param("git rebase origin/main", id="rebase stays allowed"),
]


@pytest.mark.parametrize("command", BLOCKED)
def test_destructive_scanner_blocks(command: str) -> None:
    """Every destructive command is detected."""
    assert destructive.blocked_rule(command)


@pytest.mark.parametrize("command", ALLOWED)
def test_destructive_scanner_allows(command: str) -> None:
    """Text that only mentions a rule, and safe git commands, pass."""
    assert destructive.blocked_rule(command) is None


def test_destructive_scanner_names_the_rule() -> None:
    """The scanner reports which rule matched."""
    assert _scan.find_destructive("git branch -D old") == "branch -D"


def test_push_main_from_a_different_repo_is_allowed(tmp_path: Path) -> None:
    """A cd or git -C into a genuinely different repo exempts the push."""
    other = _make_repo_with_remote(tmp_path / "other")
    assert _scan.find_destructive(f"cd {other} && git push origin main") is None
    assert _scan.find_destructive(f"git -C {other} push origin main") is None


@pytest.mark.parametrize(
    "template",
    [
        "cd $(touch {marker}) && git push origin main",
        "cd `touch {marker}` && git push origin main",
        'cd "$(touch {marker})" && git push origin main',
        "cd {other}$(touch {marker}) && git push origin main",
    ],
)
def test_the_cd_target_is_never_evaluated(template: str, tmp_path: Path) -> None:
    """A substitution in the cd target must neither run nor exempt the push."""
    other = _make_repo_with_remote(tmp_path / "other")
    marker = tmp_path / "evaluated"
    command = template.format(marker=marker, other=other)
    assert _scan.find_destructive(command) == "push origin main/master"
    assert not marker.exists()


def test_a_quoted_cd_target_is_understood(tmp_path: Path) -> None:
    """A quoted path with a space still names the other repository."""
    other = _make_repo_with_remote(tmp_path / "other dir")
    assert _scan.find_destructive(f'cd "{other}" && git push origin main') is None


def test_push_all_from_a_different_repo_is_allowed(tmp_path: Path) -> None:
    """The cd exemption also covers a push that reaches main through --all."""
    other = _make_repo_with_remote(tmp_path / "other")
    assert _scan.find_destructive(f"git -C {other} push --all") is None


def test_a_repo_can_switch_off_a_rule_by_name(project: Path) -> None:
    """`koopa.allowGitRules` in the project's git config lifts only the named rules."""
    _git(project, "config", "--add", "koopa.allowGitRules", "push origin main/master")
    _git(project, "config", "--add", "koopa.allowGitRules", "stash pop")
    assert _scan.find_destructive("git push origin main") is None
    assert _scan.find_destructive("git stash pop") is None
    assert _scan.find_destructive("git stash drop") == "stash drop"
    assert _scan.find_destructive("git reset --hard") == "reset --hard"


def test_an_unparseable_command_raises() -> None:
    """The shell parser raises rather than guessing on an unterminated quote."""
    with pytest.raises(_shell.ParseError):
        _scan.find_destructive('echo "unterminated git reset --hard')


def test_fallback_patterns_decide_when_the_parser_cannot() -> None:
    """An unparseable command is judged by the original text patterns."""
    assert destructive.blocked_rule('echo "oops git reset --hard') == "reset --hard"
    assert destructive.blocked_rule('echo "oops; git push origin main') == "push origin main/master"
    assert destructive.blocked_rule('echo "oops; git push -f origin x') == "push -f "
    assert destructive.blocked_rule('echo "oops; ls -la') is None


def test_fallback_has_no_cd_exemption(tmp_path: Path) -> None:
    """The text fallback blocks a push to main even after a cd into another repo."""
    other = _make_repo_with_remote(tmp_path / "other")
    command = f'echo "oops; cd {other} && git push origin main'
    assert destructive.fallback_rule(command) == "push origin main/master"


# ---------------------------------------------------------------------------
# guard_git_scan.py: push
# ---------------------------------------------------------------------------


@pytest.mark.parametrize(
    ("command", "expected"),
    [
        ("git push", True),
        ("git push origin feature", True),
        ("git -C /some/repo push", True),
        ("cd /x && git push", True),
        ("git status", False),
        ("git pull", False),
        ("grep -rn 'git push' docs", False),
        ('git commit -m "run git push later"', False),
    ],
)
def test_push_scanner(command: str, expected: bool) -> None:
    """Only a command that runs git push counts as a push."""
    assert _scan.runs_git_push(command) is expected
    assert secrets.is_push(command) is expected


def test_push_falls_back_to_text_pattern() -> None:
    """An unparseable command is a push when the text says so."""
    assert secrets.is_push('echo "oops; git push origin x')
    assert not secrets.is_push('echo "oops; git status')


# ---------------------------------------------------------------------------
# block_destructive_git.py: the real entry
# ---------------------------------------------------------------------------


def test_destructive_entry_blocks_claude_payload(project: Path) -> None:
    """A Claude payload that runs a destructive command exits 2 and names the rule."""
    code, stderr = _run(_DESTRUCTIVE, _claude("git branch -D old"), project, project)
    assert code == 2
    decision = json.loads(stderr)
    assert decision["decision"] == "block"
    assert "branch -D" in decision["reason"]
    assert "run it yourself" in decision["reason"]
    assert "override" not in decision["reason"]


def test_destructive_entry_blocks_copilot_batch(project: Path) -> None:
    """A destructive command hidden in a later toolCalls[] entry still blocks."""
    code, _stderr = _run(_DESTRUCTIVE, _copilot("ls -la", "git reset --hard"), project, project)
    assert code == 2


def test_destructive_entry_blocks_via_text_fallback(project: Path) -> None:
    """An unparseable command that contains a rule is blocked by the fallback."""
    code, stderr = _run(_DESTRUCTIVE, _claude('echo "oops git reset --hard'), project, project)
    assert code == 2
    assert "reset --hard" in stderr


def test_destructive_entry_allows_text_that_only_mentions_a_rule(project: Path) -> None:
    """A grep or commit message that mentions a rule passes."""
    assert _run(_DESTRUCTIVE, _claude("grep -rn 'reset --hard' docs"), project, project)[0] == 0
    assert _run(_DESTRUCTIVE, _copilot('grep -n "rm -rf" some_file.py'), project, project)[0] == 0


def test_destructive_entry_allows_plain_shell_rm_rf(project: Path, tmp_path: Path) -> None:
    """A shell rm -rf on a scratch dir is not a git command."""
    command = f'rm -rf "{tmp_path}/scratch"'
    assert _run(_DESTRUCTIVE, _claude(command), project, project)[0] == 0


def test_destructive_entry_blocks_git_rm_rf(project: Path) -> None:
    """A recursive forced git rm stays blocked."""
    assert _run(_DESTRUCTIVE, _claude("git rm -rf somedir"), project, project)[0] == 2


def test_destructive_entry_blocks_push_main_with_no_cd(project: Path) -> None:
    """A bare push to main from the project repo is blocked."""
    assert _run(_DESTRUCTIVE, _claude("git push origin main"), project, project)[0] == 2


def test_destructive_entry_blocks_cd_dot_then_push(project: Path) -> None:
    """A same-repo cd must not exempt the push."""
    assert _run(_DESTRUCTIVE, _claude("cd . && git push origin main"), project, project)[0] == 2
    command = 'cd "$(pwd)" && git push origin main'
    assert _run(_DESTRUCTIVE, _claude(command), project, project)[0] == 2


def test_destructive_entry_allows_push_from_a_different_repo(project: Path, tmp_path: Path) -> None:
    """A cd or git -C into a genuinely different repo exempts the push."""
    other = _make_repo_with_remote(tmp_path / "other")
    for command in (f"cd {other} && git push origin main", f"git -C {other} push origin main"):
        assert _run(_DESTRUCTIVE, _claude(command), project, project)[0] == 0, command


@pytest.mark.parametrize(
    "template",
    [
        "cd $(touch {marker}) && git push origin main",
        "cd `touch {marker}` && git push origin main",
        'cd "$(touch {marker})" && git push origin main',
        "cd {other}$(touch {marker}) && git push origin main",
    ],
)
def test_destructive_entry_never_runs_the_cd_target(
    template: str, project: Path, tmp_path: Path
) -> None:
    """The real hook blocks and never evaluates a substitution in the cd target."""
    other = _make_repo_with_remote(tmp_path / "other")
    marker = tmp_path / "hook-ran-this"
    command = template.format(marker=marker, other=other)
    assert _run(_DESTRUCTIVE, _claude(command), project, project)[0] == 2
    assert not marker.exists()


def test_destructive_entry_quoted_and_home_relative_targets(project: Path, tmp_path: Path) -> None:
    """Literal parsing keeps the other-repo exemption for quoted and ~/ paths only."""
    other = _make_repo_with_remote(tmp_path / "other_repo")
    allowed = [
        f'cd "{other}" && git push origin main',
        f"cd '{other}' && git push origin main",
        "cd ~/other_repo/repo && git push origin main",
    ]
    blocked = [
        f'cd "{project}" && git push origin main',
        "cd ~/other_repo/* && git push origin main",
    ]
    for command in allowed:
        assert _run(_DESTRUCTIVE, _claude(command), project, project, tmp_path)[0] == 0, command
    for command in blocked:
        assert _run(_DESTRUCTIVE, _claude(command), project, project, tmp_path)[0] == 2, command


@pytest.mark.parametrize(
    "template",
    [
        "cd {other} > /dev/null && git push origin main",
        "echo start\ncd {other} && git push origin main",
    ],
    ids=["cd with redirect", "cd on a later line"],
)
def test_destructive_entry_cd_variants_are_allowed(
    template: str, project: Path, tmp_path: Path
) -> None:
    """Pin two known disagreements with the older bash-text implementation.

    A text scan blocked a cd whose target carried a redirect, and a cd that was not on
    the first line. The parser-based scanner strips the redirect and walks every line,
    so it reads the cd target as the other repository and allows the push. The cd
    really does leave the project repository, so allowing is defensible. These tests
    pin the behavior so a change is noticed.
    """
    other = _make_repo_with_remote(tmp_path / "other_repo")
    command = template.format(other=other)
    assert _run(_DESTRUCTIVE, _claude(command), project, project)[0] == 0


@pytest.mark.parametrize("entry", [_DESTRUCTIVE, _SECRETS], ids=["destructive", "secrets"])
def test_entry_allows_a_batch_with_no_command_field(entry: Path, project: Path) -> None:
    """A toolCalls[] batch whose entries carry no command defers instead of crashing."""
    payload = json.dumps({"toolCalls": [{"args": {"path": "a.py"}}]})
    assert _run(entry, payload, project, project)[0] == 0


@pytest.mark.parametrize("entry", [_DESTRUCTIVE, _SECRETS], ids=["destructive", "secrets"])
@pytest.mark.parametrize("stdin", ["", "   \n", "{not json", "[1, 2]", "{}", '{"tool_input": "x"}'])
def test_entry_fails_open_on_empty_or_malformed_stdin(
    entry: Path, stdin: str, project: Path
) -> None:
    """Empty, malformed, or unrecognized input exits 0."""
    assert _run(entry, stdin, project, project)[0] == 0


# ---------------------------------------------------------------------------
# audit_secrets_before_push.py: the real entry
# ---------------------------------------------------------------------------


def test_secrets_entry_blocks_a_secret_in_the_outgoing_range(project: Path) -> None:
    """A committed-but-unpushed file named like .env blocks the push."""
    _commit_file(project, ".env")
    code, stderr = _run(_SECRETS, _claude("git push origin main"), project, project)
    assert code == 2
    assert ".env" in stderr
    assert json.loads(stderr.strip().splitlines()[-1])["decision"] == "block"


@pytest.mark.parametrize(
    "name", ["creds.pem", "cert.p12", "credentials.json", "secrets.yaml", "api_key.txt"]
)
def test_secrets_entry_flags_each_secret_shape(name: str, project: Path) -> None:
    """Each secret-shaped filename pattern blocks."""
    _commit_file(project, name)
    assert _run(_SECRETS, _claude("git push"), project, project)[0] == 2


def test_secrets_entry_blocks_copilot_batch(project: Path) -> None:
    """A push hidden in a later toolCalls[] entry still blocks."""
    _commit_file(project, ".env")
    assert _run(_SECRETS, _copilot("pwd", "git push origin main"), project, project)[0] == 2


def test_secrets_entry_blocks_via_text_fallback(project: Path) -> None:
    """An unparseable command that contains git push is judged by the text pattern."""
    _commit_file(project, ".env")
    assert _run(_SECRETS, _claude('echo "oops; git push'), project, project)[0] == 2


def test_secrets_entry_allows_a_clean_range(project: Path) -> None:
    """A push with no secret-shaped filename in the outgoing range passes."""
    (project / "notes.md").write_text("nothing sensitive\n")
    _git(project, "add", "notes.md")
    _git(project, "commit", "-q", "-m", "add notes")
    assert _run(_SECRETS, _claude("git push origin main"), project, project)[0] == 0


def test_secrets_entry_ignores_an_already_pushed_secret(project: Path) -> None:
    """Only the outgoing range is scanned: a secret already on the remote passes."""
    _commit_file(project, ".env")
    _git(project, "push", "-q", "origin", "main")
    assert _run(_SECRETS, _claude("git push origin main"), project, project)[0] == 0


def test_secrets_entry_ignores_a_non_push_command(project: Path) -> None:
    """A non-push command passes even with a secret in the range."""
    _commit_file(project, ".env")
    assert _run(_SECRETS, _claude("ls -la"), project, project)[0] == 0
    assert _run(_SECRETS, _claude("grep -rn 'git push' docs"), project, project)[0] == 0


def test_secrets_non_push_command_never_touches_git(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """A non-push command returns before any git call."""

    def boom(*_args: str) -> str:
        raise AssertionError("git was called")

    monkeypatch.setattr(secrets, "_git", boom)
    monkeypatch.setattr(sys, "stdin", io.StringIO(_claude("ls -la")))
    assert secrets.main() == 0


def test_secrets_entry_uses_payload_cwd_without_a_project_dir(
    project: Path, tmp_path: Path
) -> None:
    """With no CLAUDE_PROJECT_DIR (Copilot), the payload's cwd names the repository."""
    _commit_file(project, "creds.pem")
    stdin = _claude("git push origin main", cwd=str(project))
    code, stderr = _run(_SECRETS, stdin, tmp_path)
    assert code == 2
    assert "creds.pem" in stderr


def test_secrets_entry_falls_back_to_the_process_cwd(project: Path) -> None:
    """With no project dir and no payload cwd, the process cwd is the repository."""
    _commit_file(project, "creds.pem")
    assert _run(_SECRETS, _claude("git push origin main"), project)[0] == 2


def test_secrets_entry_without_an_upstream_uses_origin_branch(project: Path) -> None:
    """With no upstream configured, the range falls back to origin/<branch>..HEAD."""
    _git(project, "branch", "--unset-upstream")
    _commit_file(project, ".env")
    code, stderr = _run(_SECRETS, _claude("git push origin main"), project, project)
    assert code == 2
    assert "origin/main..HEAD" in stderr


def test_secrets_entry_does_not_block_when_git_cannot_answer(tmp_path: Path) -> None:
    """Not a repository, a missing directory, or no origin: exit 0."""
    plain = tmp_path / "plain"
    plain.mkdir()
    assert _run(_SECRETS, _claude("git push"), plain, plain)[0] == 0
    assert _run(_SECRETS, _claude("git push"), plain, tmp_path / "missing")[0] == 0
    no_origin = tmp_path / "no_origin"
    no_origin.mkdir()
    _git(no_origin, "init", "-q", "-b", "main")
    _commit_file(no_origin, ".env")
    assert _run(_SECRETS, _claude("git push"), no_origin, no_origin)[0] == 0


# ---------------------------------------------------------------------------
# registration
# ---------------------------------------------------------------------------


def test_hooks_json_files_register_all_hooks_in_order() -> None:
    """Both registries: ten Bash hooks in order, then four more groups (two hooks in one).

    The Claude and Codex file also registers the Claude Code only hooks under SessionStart,
    PreCompact and Stop; the Copilot file has PreToolUse only.
    """
    plugin = _HOOKS_DIR.parent
    claude = json.loads((plugin / "hooks" / "hooks.json").read_text())
    copilot = json.loads((plugin / "com.github.copilot" / "hooks" / "hooks.json").read_text())
    bash_hooks = [
        "block_tmux_kill_server",
        "block_destructive_git",
        "audit_secrets_before_push",
        "push_gate",
        "guard_installs",
        "block_uv",
        "guard_broad_scan",
        "guard_rm",
        "guard_hook_writes",
        "guard_sensitive_paths",
    ]
    # These read AGENT_HOOK_HARNESS to pick the Copilot output shape for their ask.
    harness_hooks = {"guard_installs", "block_uv", "guard_hook_writes", "guard_sensitive_paths"}
    for registry, root, is_copilot in (
        (claude, "${CLAUDE_PLUGIN_ROOT}", False),
        (copilot, "${PLUGIN_ROOT}", True),
    ):
        groups = registry["hooks"]["PreToolUse"]
        assert len(groups) == 5
        assert groups[0]["matcher"] == "Bash"
        prefix = "env AGENT_HOOK_HARNESS=copilot " if is_copilot else ""
        # -B: hooks import shared modules, and no __pycache__ may land under plugins/.
        expected = [
            f'{prefix if name in harness_hooks else ""}python3 -B "{root}/hooks/{name}.py"'
            for name in bash_hooks
        ]
        assert [h["command"] for h in groups[0]["hooks"]] == expected
        assert groups[1]["matcher"] == "Bash|Write|Edit|MultiEdit|NotebookEdit"
        assert [h["command"] for h in groups[1]["hooks"]] == [
            f'python3 -B "{root}/hooks/guard_tmp.py"'
        ]
        assert groups[2]["matcher"] == "Write|Edit|MultiEdit"
        assert [h["command"] for h in groups[2]["hooks"]] == [
            f'python3 -B "{root}/hooks/guard_report_path.py"'
        ]
        assert groups[3]["matcher"] == "Edit|Write|MultiEdit|NotebookEdit"
        assert [h["command"] for h in groups[3]["hooks"]] == [
            f'python3 -B "{root}/hooks/guard_keywords.py"',
            f'python3 -B "{root}/hooks/guard_secret_content.py"',
        ]
        assert groups[4]["matcher"] == "Edit|Write|Read|Bash"
        assert [h["command"] for h in groups[4]["hooks"]] == [
            f'python3 -B "{root}/hooks/guard_env_files.py"'
        ]
    # Copilot: PreToolUse only. The Claude Code only hooks must not be registered there.
    assert set(copilot["hooks"]) == {"PreToolUse"}
    assert set(claude["hooks"]) == {"PreToolUse", "SessionStart", "PreCompact", "Stop"}
    start = claude["hooks"]["SessionStart"]
    stop = claude["hooks"]["Stop"]
    compact = claude["hooks"]["PreCompact"]
    assert len(start) == 1
    assert "matcher" not in start[0]
    assert [h["command"] for h in start[0]["hooks"]] == [
        'python3 -B "${CLAUDE_PLUGIN_ROOT}/hooks/guard_settings_keywords.py"',
        'python3 -B "${CLAUDE_PLUGIN_ROOT}/hooks/guard_workspace_root.py"',
        'python3 -B "${CLAUDE_PLUGIN_ROOT}/hooks/session_local_time.py"',
        'python3 -B "${CLAUDE_PLUGIN_ROOT}/hooks/session_compact_snapshot.py"',
    ]
    # No matcher: PreCompact fires on both the manual and the automatic trigger.
    assert len(compact) == 1
    assert "matcher" not in compact[0]
    assert [h["command"] for h in compact[0]["hooks"]] == [
        'python3 -B "${CLAUDE_PLUGIN_ROOT}/hooks/session_compact_snapshot.py"'
    ]
    assert len(stop) == 1
    assert "matcher" not in stop[0]
    assert [h["command"] for h in stop[0]["hooks"]] == [
        'python3 -B "${CLAUDE_PLUGIN_ROOT}/hooks/guard_settings_keywords.py"'
    ]
    copilot_text = json.dumps(copilot)
    for claude_only in ("guard_settings_keywords", "guard_workspace_root", "session_"):
        assert claude_only not in copilot_text
    # Totals: 15 PreToolUse + 4 SessionStart + 1 PreCompact + 1 Stop in the Claude file,
    # 15 in the Copilot file.
    assert sum(len(g["hooks"]) for e in claude["hooks"].values() for g in e) == 21
    assert sum(len(g["hooks"]) for g in copilot["hooks"]["PreToolUse"]) == 15
    for group in copilot["hooks"]["PreToolUse"]:
        assert all(h["timeout"] == 5 for h in group["hooks"])
    for event in claude["hooks"].values():
        for group in event:
            assert all("timeout" not in h for h in group["hooks"])
    for name in [
        *bash_hooks,
        "guard_tmp",
        "guard_report_path",
        "guard_keywords",
        "guard_secret_content",
        "guard_env_files",
        "guard_settings_keywords",
        "guard_workspace_root",
    ]:
        assert (_HOOKS_DIR / f"{name}.py").is_file()
