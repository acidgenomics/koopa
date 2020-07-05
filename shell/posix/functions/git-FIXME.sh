#!/bin/sh

koopa::git_branch() { # {{{1
    # """
    # Current git branch name.
    # @note Updated 2020-07-04.
    #
    # This is used in prompt, so be careful with assert checks.
    #
    # Handles detached HEAD state.
    #
    # Alternatives:
    # > git name-rev --name-only HEAD
    # > git rev-parse --abbrev-ref HEAD
    #
    # @seealso
    # - https://git.kernel.org/pub/scm/git/git.git/tree/contrib/completion/
    #       git-completion.bash?id=HEAD
    # """
    koopa::assert_has_no_args "$#"
    koopa::is_git || return 1
    koopa::is_installed git || return 1
    local branch
    branch="$(git symbolic-ref --short -q HEAD 2>/dev/null)"
    koopa::print "$branch"
    return 0
}

koopa::git_clone() { # {{{1
    # """
    # Quietly clone a git repository.
    # @note Updated 2020-07-04.
    # """
    koopa::assert_has_args "$#"
    koopa::assert_is_installed git
    local repo target
    repo="${1:?}"
    target="${2:?}"
    if [ -d "$target" ]
    then
        koopa::note "Already cloned: '${target}'."
        return 0
    fi
    # Check if user has sufficient permissions.
    if koopa::str_match "$repo" 'git@github.com'
    then
        koopa::assert_is_github_ssh_enabled
    elif koopa::str_match "$repo" 'git@gitlab.com'
    then
        koopa::assert_is_gitlab_ssh_enabled
    fi
    git clone --quiet --recursive "$repo" "$target"
    return 0
}

koopa::git_last_commit_local() { # {{{1
    # """
    # Last git commit of local repository.
    # @note Updated 2020-07-04.
    #
    # Alternate:
    # Can use '%h' for abbreviated commit ID.
    # > git log --format="%H" -n 1
    # """
    koopa::assert_has_no_args "$#"
    koopa::assert_is_git
    koopa::assert_is_installed git
    local x
    x="$(git rev-parse HEAD 2>/dev/null || true)"
    [ -n "$x" ] || return 1
    koopa::print "$x"
}

koopa::git_last_commit_remote() { # {{{1
    # """
    # Last git commit of remote repository.
    # @note Updated 2020-06-30.
    #
    # Instead of 'HEAD', can use 'refs/heads/master'
    # """
    koopa::assert_has_args "$#"
    koopa::is_git || return 1
    koopa::is_installed git || return 1
    local url x
    url="${1:?}"
    x="$(git ls-remote "$url" HEAD 2>/dev/null || true)"
    [ -n "$x" ] || return 1
    koopa::print "$x"
}

koopa::git_remote_url() { # {{{1
    # """
    # Return the git remote url for origin.
    # @note Updated 2020-07-04.
    # """
    koopa::assert_has_no_args "$#"
    koopa::is_git || return 1
    koopa::is_installed git || return 1
    x="$(git config --get 'remote.origin.url')"
    koopa::print "$x"
    return 0
}

koopa::git_rm_submodule() { # {{{1
    # """
    # Remove a git submodule.
    # @note Updated 2020-07-04.
    #
    # @seealso
    # - https://stackoverflow.com/questions/1260748/
    # - https://gist.github.com/myusuf3/7f645819ded92bda6677
    # """
    koopa::assert_has_args "$#"
    koopa::assert_is_git
    koopa::assert_is_installed git
    local module
    for module in "$@"
    do
        # Remove the submodule entry from '.git/config'.
        git submodule deinit -f "$module"
        # Remove the submodule directory from the superproject's '.git/modules'
        # directory.
        rm -fr ".git/modules/${module}"
        # Remove the entry in '.gitmodules' and remove the submodule directory
        # located at 'path/to/submodule'.
        git rm -f "$module"
        # Update gitmodules file and commit.
        git add '.gitmodules'
        git commit -m "Removed submodule '${module}'."
    done
    return 0
}

koopa::git_rm_untracked() { # {{{1
    # """
    # Remove untracked files from git repo.
    # @note Updated 2020-07-04.
    # """
    koopa::assert_has_no_args "$#"
    koopa::assert_is_git
    koopa::assert_is_installed git
    git clean -dfx
    return 0
}

koopa::git_set_remote_url() {
    # """
    # Set (or change) the remote URL of a git repo.
    # @note Updated 2020-07-04.
    # """
    koopa::assert_has_args_eq "$#" 1
    koopa::assert_is_git
    koopa::assert_is_installed git
    local url
    url="${1:?}"
    git remote set-url origin "$url"
    return 0
}
