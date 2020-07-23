#!/usr/bin/env bash

koopa::git_clone() { # {{{1
    # """
    # Quietly clone a git repository.
    # @note Updated 2020-07-04.
    # """
    local repo target
    koopa::assert_has_args "$#"
    koopa::assert_is_installed git
    repo="${1:?}"
    target="${2:?}"
    if [[ -d "$target" ]]
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

koopa::git_init() { # {{{1
    repo="${1:-}"
    koopa::assert_has_args_le "$#" 1
    git init
    if [[ -n "$repo" ]]
    then
        git remote add 'origin' "$repo"
        git remote -v
        git fetch --all
        git branch --set-upstream-to='origin/master' 'master'
        git pull 'origin' 'master' --allow-unrelated-histories
    fi
    git status
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
    local x
    koopa::assert_has_no_args "$#"
    koopa::assert_is_git
    koopa::assert_is_installed git
    x="$(git rev-parse HEAD 2>/dev/null || true)"
    [[ -n "$x" ]] || return 1
    koopa::print "$x"
}

koopa::git_last_commit_remote() { # {{{1
    # """
    # Last git commit of remote repository.
    # @note Updated 2020-06-30.
    #
    # Instead of 'HEAD', can use 'refs/heads/master'
    # """
    local url x
    koopa::assert_has_args "$#"
    koopa::is_git || return 1
    koopa::is_installed git || return 1
    url="${1:?}"
    x="$(git ls-remote "$url" HEAD 2>/dev/null || true)"
    [[ -n "$x" ]] || return 1
    koopa::print "$x"
}

koopa::git_pull() { # {{{1
    # """
    # Pull (update) a git repository.
    # @note Updated 2020-07-23.
    #
    # Can quiet down with 'git submodule --quiet' here.
    # Note that git checkout, fetch, and pull also support '--quiet'.
    #
    # @seealso
    # - https://git-scm.com/docs/git-submodule/2.10.2
    # """
    local branch
    branch=
    [[ "$#" -gt 0 ]] && branch="${*: -1}"
    koopa::info "Pulling git repo at '${PWD:?}'."
    koopa::assert_is_git
    koopa::assert_is_installed git
    git fetch --all
    git pull "$@"
    if [[ -s '.gitmodules' ]]
    then
        koopa::git_submodule_init
        git submodule --quiet update --init --recursive
        git submodule --quiet foreach --recursive \
            git fetch --all --quiet
        if [[ -n "$branch" ]]
        then
            git submodule --quiet foreach --recursive \
                git checkout "$branch" --quiet
            git submodule --quiet foreach --recursive \
                git pull "$@"
        fi
    fi
    koopa::success 'Pull was successful.'
    return 0
}

koopa::git_pull_recursive() { # {{{1
    local dir repo repos
    koopa::assert_has_args_le "$#" 1
    dir="${1:-.}"
    dir="$(realpath "$dir")"
    # Using '-L' flag here in case git dir is a symlink.
    readarray -t repos <<< "$( \
        find -L "$dir" \
            -mindepth 1 \
            -maxdepth 2 \
            -name '.git' \
            -print \
    )"
    if ! koopa::is_array_non_empty "${repos[@]}"
    then
        koopa::stop 'Failed to detect any git repos.'
    fi
    koopa::h1 "Pulling ${#repos[@]} git repos at '${dir}'."
    for repo in "${repos[@]}"
    do
        repo="$(dirname "$repo")"
        koopa::h2 "$repo"
        (
            koopa::cd "$repo"
            git fetch --all
            git pull --all
            git status
        )
    done
    return 0
}

koopa::git_push_recursive() { # {{{1
    local dir repo repos
    koopa::assert_has_args_le "$#" 1
    dir="${1:-.}"
    dir="$(realpath "$dir")"
    # Using '-L' flag here in case git dir is a symlink.
    readarray -t repos <<< "$( \
        find -L "$dir" \
            -mindepth 1 \
            -maxdepth 2 \
            -name '.git' \
            -print \
    )"
    if ! koopa::is_array_non_empty "${repos[@]}"
    then
        koopa::stop 'Failed to detect any git repos.'
    fi
    koopa::h1 "Pushing ${#repos[@]} git repos at '${dir}'."
    for repo in "${repos[@]}"
    do
        repo="$(dirname "$repo")"
        koopa::h2 "$repo"
        (
            koopa::cd "$repo"
            git push
        )
    done
    return 0
}

koopa::git_push_submodules() { # {{{1
    local dir
    koopa::assert_has_args_le "$#" 1
    dir="${1:-.}"
    (
        koopa::cd "$dir"
        git submodule update --remote --merge
        git commit -m 'Update submodules.'
        git push
    )
    return 0
}

koopa::git_remote_url() { # {{{1
    # """
    # Return the git remote url for origin.
    # @note Updated 2020-07-04.
    # """
    local x
    koopa::assert_has_no_args "$#"
    koopa::is_git || return 1
    koopa::is_installed git || return 1
    x="$(git config --get 'remote.origin.url')"
    koopa::print "$x"
    return 0
}

koopa::git_reset() { # {{{1
    # """
    # Clean and reset a git repo and its submodules.
    # @note Updated 2020-07-04.
    #
    # Note extra '-f' flag in 'git clean' step, which handles nested '.git'
    # directories better.
    #
    # Additional steps:
    # # Ensure accidental swap files created by vim get nuked.
    # > find . -type f -name '*.swp' -delete
    # # Ensure invisible files get nuked on macOS.
    # > if koopa::is_macos
    # > then
    # >     find . -type f -name '.DS_Store' -delete
    # > fi
    #
    # See also:
    # https://gist.github.com/nicktoumpelis/11214362
    # """
    koopa::assert_has_no_args "$#"
    koopa::info "Resetting git repo at '${PWD:?}'."
    koopa::assert_is_git
    koopa::assert_is_installed git
    git clean -dffx
    if [[ -s '.gitmodules' ]]
    then
        koopa::git_submodule_init
        git submodule --quiet foreach --recursive git clean -dffx
        git reset --hard --quiet
        git submodule --quiet foreach --recursive git reset --hard --quiet
    fi
    return 0
}

koopa::git_reset_fork_to_upstream() { # {{{1
    local dir
    koopa::assert_has_args_le "$#" 1
    dir="${1:-.}"
    (
        koopa::cd "$dir"
        git checkout 'master'
        git fetch upstream
        git reset --hard 'upstream/master'
        git push 'origin' 'master' --force
    )
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
    local module
    koopa::assert_has_args "$#"
    koopa::assert_is_git
    koopa::assert_is_installed git
    for module in "$@"
    do
        # Remove the submodule entry from '.git/config'.
        git submodule deinit -f "$module"
        # Remove the submodule directory from the superproject's '.git/modules'
        # directory.
        koopa::rm ".git/modules/${module}"
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

koopa::git_set_remote_url() { # {{{1
    # """
    # Set (or change) the remote URL of a git repo.
    # @note Updated 2020-07-04.
    # """
    local url
    koopa::assert_has_args_eq "$#" 1
    koopa::assert_is_git
    koopa::assert_is_installed git
    url="${1:?}"
    git remote set-url origin "$url"
    return 0
}

koopa::git_status_recursive() { # {{{1
    local dir repo repos
    koopa::assert_has_args_le "$#" 1
    dir="${1:-.}"
    dir="$(realpath "$dir")"
    # Using '-L' flag here in case git dir is a symlink.
    readarray -t repos <<< "$( \
        find -L "$dir" \
            -mindepth 1 \
            -maxdepth 2 \
            -name '.git' \
            -print \
    )"
    if ! koopa::is_array_non_empty "${repos[@]}"
    then
        koopa::stop 'Failed to detect any git repos.'
    fi
    koopa::h1 "Checking status of ${#repos[@]} git repos at '${dir}'."
    for repo in "${repos[@]}"
    do
        repo="$(dirname "$repo")"
        koopa::h2 "$repo"
        (
            koopa::cd "$repo"
            git status
        )
    done
    return 0
}

koopa::git_submodule_init() { # {{{1
    # """
    # Initialize git submodules.
    # @note Updated 2020-07-04.
    # """
    local array lines string target target_key url url_key
    koopa::assert_has_no_args "$#"
    koopa::info "Initializing submodules in '${PWD:?}'."
    koopa::assert_is_git
    koopa::assert_is_nonzero_file '.gitmodules'
    koopa::assert_is_installed git
    git submodule init
    lines="$( \
        git config \
            -f '.gitmodules' \
            --get-regexp '^submodule\..*\.path$' \
    )"
    readarray -t array <<< "$lines"
    if ! koopa::is_array_non_empty "${array[@]}"
    then
        koopa::stop "Failed to detect submodules in '${PWD}'."
    fi
    for string in "${array[@]}"
    do
        target_key="$(koopa::print "$string" | cut -d ' ' -f 1)"
        target="$(koopa::print "$string" | cut -d ' ' -f 2)"
        url_key="${target_key//\.path/.url}"
        url="$(git config -f '.gitmodules' --get "$url_key")"
        koopa::dl "$target" "$url"
        if [[ ! -d "$target" ]]
        then
            git submodule add --force "$url" "$target" > /dev/null
        fi
    done
    return 0
}
