#!/bin/sh
# shellcheck disable=SC2039

koopa::git_branch() { # {{{1
    # """
    # Current git branch name.
    # @note Updated 2020-07-03.
    #
    # Handles detached HEAD state.
    #
    # Alternatives:
    # > git name-rev --name-only HEAD
    # > git rev-parse --abbrev-ref HEAD
    #
    # See also:
    # - https://git.kernel.org/pub/scm/git/git.git/tree/contrib/completion/
    #       git-completion.bash?id=HEAD
    # """
    koopa::assert_has_no_args "$#"
    koopa::is_git || return 1
    local branch
    branch="$(git symbolic-ref --short -q HEAD 2>/dev/null)"
    koopa::print "$branch"
    return 0
}

koopa::git_clone() { # {{{1
    # """
    # Quietly clone a git repository.
    # @note Updated 2020-06-30.
    # """
    koopa::assert_has_args "$#"
    local repo target
    repo="${1:?}"
    target="${2:?}"
    if [ -d "$target" ]
    then
        koopa::note "Cloned: '${target}'."
        return 0
    fi
    git clone --quiet --recursive "$repo" "$target"
    return 0
}

koopa::git_last_commit_local() { # {{{1
    # """
    # Last git commit of local repository.
    # @note Updated 2020-04-08.
    #
    # Alternate:
    # Can use '%h' for abbreviated commit ID.
    # > git log --format="%H" -n 1
    # """
    koopa::assert_has_no_args "$#"
    koopa::is_git || return 1
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
    local url x
    url="${1:?}"
    x="$(git ls-remote "$url" HEAD 2>/dev/null || true)"
    [ -n "$x" ] || return 1
    koopa::print "$x"
}

koopa::git_rm_submodule() { # {{{1
    # """
    # Remove a git submodule.
    # @note Updated 2020-06-30.
    #
    # @seealso
    # - https://stackoverflow.com/questions/1260748/
    # - https://gist.github.com/myusuf3/7f645819ded92bda6677
    # """
    koopa::assert_is_installed git
    local prefix
    prefix="${1:-"."}"
    # Remove the submodule entry from '.git/config'.
    git submodule deinit -f "$prefix"
    # Remove the submodule directory from the superproject's '.git/modules'
    # directory.
    rm -fr ".git/modules/${prefix}"
    # Remove the entry in '.gitmodules' and remove the submodule directory
    # located at 'path/to/submodule'.
    git rm -f "$prefix"
    # Update gitmodules file and commit.
    git add .gitmodules
    git commit -m "Removed submodule '${prefix}'."
    return 0
}

koopa::git_rm_untracked() { # {{{1
    # """
    # Remove untracked files from git repo.
    # @note Updated 2020-06-30.
    # """
    koopa::assert_is_installed git
    local dir
    dir="${1:-"."}"
    git clean -dfx "$dir"
    return 0
}
