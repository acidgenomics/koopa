"""Git operations.

Converted from Bash functions: git-clone, git-pull, git-default-branch,
git-last-commit-local, git-last-commit-remote, git-latest-tag,
git-push-submodules, git-submodule-init, git-reset, git-rm-untracked,
git-rename-master-to-main, git-set-remote-url, git-rm-submodule, etc.
"""

from __future__ import annotations

import os
import shutil
import subprocess


def _git(
    *args: str,
    cwd: str | None = None,
    capture: bool = True,
) -> subprocess.CompletedProcess:
    """Run a git command."""
    cmd = ["git", *args]
    return subprocess.run(
        cmd,
        cwd=cwd,
        capture_output=capture,
        text=True,
        check=True,
    )


def git_clone(
    url: str,
    target: str | None = None,
    *,
    branch: str | None = None,
    recursive: bool = False,
) -> None:
    """Clone a git repository."""
    args = ["clone"]
    if branch:
        args.extend(["--branch", branch])
    if recursive:
        args.append("--recursive")
    args.append(url)
    if target:
        args.append(target)
    _git(*args, capture=False)


def git_pull(path: str = ".", *, rebase: bool = False) -> None:
    """Pull latest changes."""
    args = ["pull"]
    if rebase:
        args.append("--rebase")
    _git(*args, cwd=path, capture=False)


def git_branch(path: str = ".") -> str:
    """Get current branch name."""
    result = _git("rev-parse", "--abbrev-ref", "HEAD", cwd=path)
    return result.stdout.strip()


def git_default_branch(path: str = ".") -> str:
    """Get the default branch name (main or master)."""
    result = _git("symbolic-ref", "refs/remotes/origin/HEAD", cwd=path)
    ref = result.stdout.strip()
    return ref.rsplit("/", maxsplit=1)[-1]


def git_last_commit_local(path: str = ".") -> str:
    """Get the last local commit SHA."""
    result = _git("rev-parse", "HEAD", cwd=path)
    return result.stdout.strip()


def git_last_commit_remote(path: str = ".", *, branch: str | None = None) -> str:
    """Get the last remote commit SHA."""
    if branch is None:
        branch = git_default_branch(path)
    result = _git("rev-parse", f"origin/{branch}", cwd=path)
    return result.stdout.strip()


def git_remote_url(path: str = ".") -> str:
    """Get remote origin URL."""
    result = _git("config", "--get", "remote.origin.url", cwd=path)
    return result.stdout.strip()


def git_latest_tag(path: str = ".") -> str:
    """Get the latest git tag."""
    result = _git("describe", "--tags", "--abbrev=0", cwd=path)
    return result.stdout.strip()


def git_push_submodules(path: str = ".") -> None:
    """Push all submodules."""
    _git("push", "--recurse-submodules=on-demand", cwd=path, capture=False)


def git_submodule_init(path: str = ".") -> None:
    """Initialize and update submodules."""
    _git("submodule", "update", "--init", "--recursive", cwd=path, capture=False)


def git_reset(path: str = ".", *, hard: bool = False) -> None:
    """Reset git repository."""
    args = ["reset"]
    if hard:
        args.append("--hard")
    _git(*args, cwd=path, capture=False)


def git_rm_untracked(path: str = ".") -> None:
    """Remove untracked files."""
    _git("clean", "-fdx", cwd=path, capture=False)


def git_rename_master_to_main(path: str = ".") -> None:
    """Rename master branch to main."""
    _git("branch", "-m", "master", "main", cwd=path)
    _git("push", "-u", "origin", "main", cwd=path, capture=False)


def git_set_remote_url(url: str, path: str = ".") -> None:
    """Set the remote origin URL."""
    _git("remote", "set-url", "origin", url, cwd=path)


def git_rm_submodule(submodule: str, path: str = ".") -> None:
    """Remove a git submodule."""
    _git("submodule", "deinit", "-f", submodule, cwd=path)
    git_dir = os.path.join(path, ".git", "modules", submodule)
    if os.path.isdir(git_dir):
        shutil.rmtree(git_dir)
    _git("rm", "-f", submodule, cwd=path)


def git_commit_date(path: str = ".", *, ref: str = "HEAD") -> str:
    """Get commit date in ISO format."""
    result = _git("log", "-1", "--format=%aI", ref, cwd=path)
    return result.stdout.strip()


def git_repo_has_unstaged_changes(path: str = ".") -> bool:
    """Check if repository has unstaged changes."""
    result = subprocess.run(
        ["git", "diff", "--quiet"],
        cwd=path,
        capture_output=True,
        check=False,
    )
    return result.returncode != 0


def git_repo_needs_pull_or_push(path: str = ".") -> bool:
    """Check if repository needs a pull or push."""
    _git("fetch", cwd=path)
    local = git_last_commit_local(path)
    try:
        remote = git_last_commit_remote(path)
    except subprocess.CalledProcessError:
        return False
    return local != remote


def git_reset_fork_to_upstream(path: str = ".") -> None:
    """Reset a fork to match upstream."""
    branch = git_default_branch(path)
    _git("fetch", "upstream", cwd=path)
    _git("checkout", branch, cwd=path)
    _git("reset", "--hard", f"upstream/{branch}", cwd=path)
    _git("push", "origin", branch, "--force", cwd=path, capture=False)


def assert_is_git_repo(path: str = ".") -> None:
    """Assert that a directory is a git repository."""
    git_dir = os.path.join(path, ".git")
    if not os.path.isdir(git_dir):
        msg = f"Not a git repository: '{path}'."
        raise NotADirectoryError(msg)


def is_git_repo(path: str = ".") -> bool:
    """Check if a directory is a git repository."""
    return os.path.isdir(os.path.join(path, ".git"))


def git_status(path: str = ".") -> str:
    """Get git status."""
    result = _git("status", "--porcelain", cwd=path)
    return result.stdout.strip()


def git_log(path: str = ".", *, n: int = 10, oneline: bool = True) -> str:
    """Get git log."""
    args = ["log", f"-{n}"]
    if oneline:
        args.append("--oneline")
    result = _git(*args, cwd=path)
    return result.stdout.strip()


def git_diff(path: str = ".", *, staged: bool = False) -> str:
    """Get git diff."""
    args = ["diff"]
    if staged:
        args.append("--staged")
    result = _git(*args, cwd=path)
    return result.stdout.strip()


def git_stash(path: str = ".") -> None:
    """Stash changes."""
    _git("stash", cwd=path, capture=False)


def git_stash_pop(path: str = ".") -> None:
    """Pop stashed changes."""
    _git("stash", "pop", cwd=path, capture=False)
