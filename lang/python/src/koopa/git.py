"""Git operations.

Converted from Bash functions: git-clone, git-pull, git-default-branch,
git-last-commit-local, git-last-commit-remote, git-latest-tag,
git-push-submodules, git-submodule-init, git-reset, git-rm-untracked,
git-rename-master-to-main, git-set-remote-url, git-rm-submodule, etc.
"""

import os
import shutil
import subprocess
import time


def _git(
    *args: str,
    cwd: str | None = None,
    capture: bool = True,
) -> subprocess.CompletedProcess:
    """Run a git command.

    Parameters
    ----------
    *args : str
        Git subcommand and arguments to pass to the ``git`` executable.
    cwd : str | None, optional
        Directory to run the command in.
    capture : bool, optional
        True to capture stdout and stderr instead of printing to the console.

    Returns
    -------
    subprocess.CompletedProcess
        Result of the completed ``git`` invocation.
    """
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
    commit: str | None = None,
    tag: str | None = None,
    recursive: bool = False,
    retries: int = 3,
) -> None:
    """Clone a git repository.

    Matches bash ``koopa_git_clone`` behaviour:
    - branch: shallow clone with ``--depth=1 --single-branch``
    - commit/tag: blobless clone with ``--filter=blob:none``, then checkout
    - retries: retry up to this many times on network errors (default: 3)

    Parameters
    ----------
    url : str
        Repository URL to clone.
    target : str | None, optional
        Directory to clone into. Defaults to git's own derived directory name.
    branch : str | None, optional
        Branch name to shallow clone.
    commit : str | None, optional
        Commit SHA to check out after a blobless clone.
    tag : str | None, optional
        Tag name to shallow clone.
    recursive : bool, optional
        True to also clone submodules recursively.
    retries : int, optional
        Number of attempts before giving up on a network error.
    """
    args = ["clone", "--quiet"]
    if branch:
        args.extend(["--depth=1", "--single-branch", "--branch", branch])
    elif tag:
        args.extend(["--depth=1", "--single-branch", "--branch", tag])
    else:
        args.append("--filter=blob:none")
    if recursive:
        args.append("--recursive")
    args.append(url)
    if target:
        args.append(target)

    for attempt in range(1, retries + 1):
        try:
            _git(*args, capture=False)
            break
        except subprocess.CalledProcessError as exc:
            stderr = (exc.stderr or "").lower()
            is_network_error = any(
                pattern in stderr
                for pattern in [
                    "connection reset",
                    "connection refused",
                    "connection timed out",
                    "rpc failed",
                    "early eof",
                    "fetch-pack",
                    "recv failure",
                    "broken pipe",
                ]
            )
            if attempt < retries and is_network_error:
                wait_time = 2 ** (attempt - 1)
                from koopa.alert import alert_info

                alert_info(
                    f"Network error during git clone (attempt {attempt}/{retries}), "
                    f"retrying in {wait_time}s..."
                )
                time.sleep(wait_time)
                if target and os.path.exists(target):
                    shutil.rmtree(target)
            else:
                raise

    cwd = target or os.path.basename(url).removesuffix(".git")
    if commit:
        _git("checkout", "--quiet", commit, cwd=cwd, capture=False)


def git_fetch(path: str = ".", *, capture: bool = False) -> subprocess.CompletedProcess | None:
    """Fetch from remote.

    Parameters
    ----------
    path : str, optional
        Repository directory to run the command in.
    capture : bool, optional
        True to capture and return the command's output.

    Returns
    -------
    subprocess.CompletedProcess | None
        Completed process if `capture` is True, otherwise None.
    """
    result = _git("fetch", "--all", cwd=path, capture=capture)
    return result if capture else None


def git_checkout(path: str = ".", *, ref: str = "HEAD") -> None:
    """Checkout a specific ref.

    Parameters
    ----------
    path : str, optional
        Repository directory to run the command in.
    ref : str, optional
        Git ref (branch, tag, or commit) to check out.
    """
    _git("checkout", ref, cwd=path, capture=False)


def git_pull(
    path: str = ".",
    *,
    rebase: bool = False,
    autostash: bool = False,
    capture: bool = False,
) -> subprocess.CompletedProcess | None:
    """Pull latest changes.

    Parameters
    ----------
    path : str, optional
        Repository directory to run the command in.
    rebase : bool, optional
        True to rebase local commits on top of the pulled changes.
    autostash : bool, optional
        True to automatically stash and restore local changes around the pull.
    capture : bool, optional
        True to capture and return the command's output.

    Returns
    -------
    subprocess.CompletedProcess | None
        Completed process if `capture` is True, otherwise None.
    """
    args = ["pull"]
    if rebase:
        args.append("--rebase")
    if autostash:
        args.append("--autostash")
    result = _git(*args, cwd=path, capture=capture)
    if capture:
        return result
    return None


def git_pull_safe(path: str) -> None:
    """Pull a git repo if clean, warn on failure without raising.

    Uses git_repo_has_unstaged_changes() to skip repos with active changes.
    On auth failure, suggests 'gh auth switch' if gh is installed.

    Parameters
    ----------
    path : str
        Repository directory to pull.
    """
    from koopa.alert import alert_info, warn

    if not os.path.isdir(path) or not is_git_repo(path):
        return
    name = os.path.basename(path)
    if git_repo_has_unstaged_changes(path):
        warn(f"Skipping pull for '{name}': repo has active changes.")
        return
    if git_branch(path) == "HEAD":
        return
    alert_info(f"Pulling '{name}'.")
    _auth_failure_patterns = (
        "repository not found",
        "not found",
        "could not read username",
        "permission denied",
        "authentication failed",
        "403",
        "401",
    )
    try:
        git_pull(path, rebase=True, autostash=True, capture=True)
    except subprocess.CalledProcessError as exc:
        stderr = (exc.stderr or "").lower()
        if any(pat in stderr for pat in _auth_failure_patterns):
            msg = f"Failed to pull '{name}': authentication error."
            if shutil.which("gh"):
                msg += " Consider running 'gh auth switch'."
            warn(msg)
        else:
            warn(f"Failed to pull '{name}': {exc}")
    except Exception as exc:
        warn(f"Failed to pull '{name}': {exc}")


def git_branch(path: str = ".") -> str:
    """Get current branch name.

    Parameters
    ----------
    path : str, optional
        Repository directory to check.

    Returns
    -------
    str
        Current branch name, or ``"HEAD"`` if in a detached-HEAD state.
    """
    result = _git("rev-parse", "--abbrev-ref", "HEAD", cwd=path)
    return result.stdout.strip()


def git_default_branch(path: str = ".") -> str:
    """Get the default branch name (main or master).

    Parameters
    ----------
    path : str, optional
        Repository directory to check.

    Returns
    -------
    str
        Name of the default branch tracked by ``origin/HEAD``.
    """
    result = _git("symbolic-ref", "refs/remotes/origin/HEAD", cwd=path)
    ref = result.stdout.strip()
    return ref.rsplit("/", maxsplit=1)[-1]


def git_last_commit_local(path: str = ".") -> str:
    """Get the last local commit SHA.

    Parameters
    ----------
    path : str, optional
        Repository directory to check.

    Returns
    -------
    str
        SHA of the current local ``HEAD`` commit.
    """
    result = _git("rev-parse", "HEAD", cwd=path)
    return result.stdout.strip()


def git_last_commit_remote(path: str = ".", *, branch: str | None = None) -> str:
    """Get the last remote commit SHA.

    Parameters
    ----------
    path : str, optional
        Repository directory to check.
    branch : str | None, optional
        Branch to check on the remote. Defaults to the repository's default
        branch.

    Returns
    -------
    str
        SHA of the latest commit on ``origin/<branch>``.
    """
    if branch is None:
        branch = git_default_branch(path)
    result = _git("rev-parse", f"origin/{branch}", cwd=path)
    return result.stdout.strip()


def git_remote_url(path: str = ".") -> str:
    """Get remote origin URL.

    Parameters
    ----------
    path : str, optional
        Repository directory to check.

    Returns
    -------
    str
        URL configured for the ``origin`` remote.
    """
    result = _git("config", "--get", "remote.origin.url", cwd=path)
    return result.stdout.strip()


def git_latest_tag(path: str = ".") -> str:
    """Get the latest git tag.

    Parameters
    ----------
    path : str, optional
        Repository directory to check.

    Returns
    -------
    str
        Most recent tag reachable from ``HEAD``.
    """
    result = _git("describe", "--tags", "--abbrev=0", cwd=path)
    return result.stdout.strip()


def git_tag_exists(tag: str, path: str = ".") -> bool:
    """Check if a git tag exists locally.

    Parameters
    ----------
    tag : str
        Tag name to look up.
    path : str, optional
        Repository directory to check.

    Returns
    -------
    bool
        True if the tag exists locally.
    """
    result = _git("tag", "--list", tag, cwd=path)
    return bool(result.stdout.strip())


def git_create_tag(tag: str, message: str, path: str = ".") -> None:
    """Create an annotated git tag.

    Parameters
    ----------
    tag : str
        Name of the tag to create.
    message : str
        Annotation message for the tag.
    path : str, optional
        Repository directory to create the tag in.
    """
    _git("tag", "-a", tag, "-m", message, cwd=path)


def git_push_tag(tag: str, path: str = ".") -> None:
    """Push a tag to origin.

    Parameters
    ----------
    tag : str
        Name of the tag to push.
    path : str, optional
        Repository directory to push from.
    """
    _git("push", "origin", tag, cwd=path, capture=False)


def git_push_submodules(path: str = ".") -> None:
    """Push all submodules.

    Parameters
    ----------
    path : str, optional
        Repository directory to push from.
    """
    _git("push", "--recurse-submodules=on-demand", cwd=path, capture=False)


def git_submodule_init(path: str = ".") -> None:
    """Initialize and update submodules.

    Parameters
    ----------
    path : str, optional
        Repository directory to run the command in.
    """
    _git("submodule", "update", "--init", "--recursive", cwd=path, capture=False)


def git_merge_abort(path: str = ".") -> None:
    """Abort an in-progress merge if one exists.

    Parameters
    ----------
    path : str, optional
        Repository directory to check.
    """
    merge_head = os.path.join(path, ".git", "MERGE_HEAD")
    if os.path.isfile(merge_head):
        _git("merge", "--abort", cwd=path, capture=False)


def git_rebase_abort(path: str = ".") -> None:
    """Abort an in-progress rebase if one exists.

    Parameters
    ----------
    path : str, optional
        Repository directory to check.
    """
    git_dir = os.path.join(path, ".git")
    rebase_in_progress = os.path.isdir(os.path.join(git_dir, "rebase-merge")) or os.path.isdir(
        os.path.join(git_dir, "rebase-apply")
    )
    if rebase_in_progress:
        _git("rebase", "--abort", cwd=path, capture=False)


def git_reset(
    path: str = ".", *, ref: str | None = None, hard: bool = False, capture: bool = False
) -> subprocess.CompletedProcess | None:
    """Reset git repository.

    Parameters
    ----------
    path : str, optional
        Repository directory to run the command in.
    ref : str | None, optional
        Ref to reset to. Defaults to git's own default (``HEAD``).
    hard : bool, optional
        True to discard working-tree and index changes as well.
    capture : bool, optional
        True to capture and return the command's output.

    Returns
    -------
    subprocess.CompletedProcess | None
        Completed process if `capture` is True, otherwise None.
    """
    args = ["reset"]
    if hard:
        args.append("--hard")
    if ref:
        args.append(ref)
    result = _git(*args, cwd=path, capture=capture)
    return result if capture else None


def git_rm_untracked(path: str = ".") -> None:
    """Remove untracked files.

    Parameters
    ----------
    path : str, optional
        Repository directory to clean.
    """
    _git("clean", "-fdx", cwd=path, capture=False)


def git_rename_master_to_main(path: str = ".") -> None:
    """Rename master branch to main.

    Parameters
    ----------
    path : str, optional
        Repository directory to run the command in.
    """
    _git("branch", "-m", "master", "main", cwd=path)
    _git("push", "-u", "origin", "main", cwd=path, capture=False)


def git_set_remote_url(url: str, path: str = ".") -> None:
    """Set the remote origin URL.

    Parameters
    ----------
    url : str
        New URL for the ``origin`` remote.
    path : str, optional
        Repository directory to run the command in.
    """
    _git("remote", "set-url", "origin", url, cwd=path)


def git_rm_submodule(submodule: str, path: str = ".") -> None:
    """Remove a git submodule.

    Parameters
    ----------
    submodule : str
        Path to the submodule, relative to the repository root.
    path : str, optional
        Repository directory containing the submodule.
    """
    _git("submodule", "deinit", "-f", submodule, cwd=path)
    git_dir = os.path.join(path, ".git", "modules", submodule)
    if os.path.isdir(git_dir):
        shutil.rmtree(git_dir)
    _git("rm", "-f", submodule, cwd=path)


def git_commit_date(path: str = ".", *, ref: str = "HEAD") -> str:
    """Get commit date in ISO format.

    Parameters
    ----------
    path : str, optional
        Repository directory to check.
    ref : str, optional
        Git ref (branch, tag, or commit) whose commit date to look up.

    Returns
    -------
    str
        Commit date in ISO 8601 format.
    """
    result = _git("log", "-1", "--format=%aI", ref, cwd=path)
    return result.stdout.strip()


def git_repo_has_unstaged_changes(path: str = ".") -> bool:
    """Check if repository has unstaged changes.

    Parameters
    ----------
    path : str, optional
        Repository directory to check.

    Returns
    -------
    bool
        True if the working tree has unstaged changes.
    """
    result = subprocess.run(
        ["git", "diff", "--quiet"],
        cwd=path,
        capture_output=True,
        check=False,
    )
    return result.returncode != 0


def git_repo_needs_pull_or_push(path: str = ".") -> bool:
    """Check if repository needs a pull or push.

    Parameters
    ----------
    path : str, optional
        Repository directory to check.

    Returns
    -------
    bool
        True if the local and remote default-branch commits differ. False
        if the remote branch cannot be resolved.
    """
    _git("fetch", cwd=path)
    local = git_last_commit_local(path)
    try:
        remote = git_last_commit_remote(path)
    except subprocess.CalledProcessError:
        return False
    return local != remote


def git_reset_fork_to_upstream(path: str = ".") -> None:
    """Reset a fork to match upstream.

    Parameters
    ----------
    path : str, optional
        Repository directory to run the command in.
    """
    branch = git_default_branch(path)
    _git("fetch", "upstream", cwd=path)
    _git("checkout", branch, cwd=path)
    _git("reset", "--hard", f"upstream/{branch}", cwd=path)
    _git("push", "origin", branch, "--force", cwd=path, capture=False)


def assert_is_git_repo(path: str = ".") -> None:
    """Assert that a directory is a git repository.

    Parameters
    ----------
    path : str, optional
        Directory to check.
    """
    git_dir = os.path.join(path, ".git")
    if not os.path.isdir(git_dir):
        msg = f"Not a git repository: '{path}'."
        raise NotADirectoryError(msg)


def is_git_repo(path: str = ".") -> bool:
    """Check if a directory is a git repository.

    Parameters
    ----------
    path : str, optional
        Directory to check.

    Returns
    -------
    bool
        True if the directory contains a ``.git`` subdirectory.
    """
    return os.path.isdir(os.path.join(path, ".git"))


def git_status(path: str = ".") -> str:
    """Get git status.

    Parameters
    ----------
    path : str, optional
        Repository directory to check.

    Returns
    -------
    str
        Porcelain-format status output.
    """
    result = _git("status", "--porcelain", cwd=path)
    return result.stdout.strip()


def git_log(path: str = ".", *, n: int = 10, oneline: bool = True) -> str:
    """Get git log.

    Parameters
    ----------
    path : str, optional
        Repository directory to check.
    n : int, optional
        Number of most recent commits to include.
    oneline : bool, optional
        True to format each commit as a single line.

    Returns
    -------
    str
        Formatted commit log.
    """
    args = ["log", f"-{n}"]
    if oneline:
        args.append("--oneline")
    result = _git(*args, cwd=path)
    return result.stdout.strip()


def git_diff(path: str = ".", *, staged: bool = False) -> str:
    """Get git diff.

    Parameters
    ----------
    path : str, optional
        Repository directory to check.
    staged : bool, optional
        True to show staged changes instead of the working-tree diff.

    Returns
    -------
    str
        Diff output.
    """
    args = ["diff"]
    if staged:
        args.append("--staged")
    result = _git(*args, cwd=path)
    return result.stdout.strip()


def git_stash(path: str = ".") -> None:
    """Stash changes.

    Parameters
    ----------
    path : str, optional
        Repository directory to run the command in.
    """
    _git("stash", cwd=path, capture=False)


def git_stash_pop(path: str = ".") -> None:
    """Pop stashed changes.

    Parameters
    ----------
    path : str, optional
        Repository directory to run the command in.
    """
    _git("stash", "pop", cwd=path, capture=False)
