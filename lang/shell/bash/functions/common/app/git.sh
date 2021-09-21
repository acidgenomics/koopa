#!/usr/bin/env bash

koopa::git_checkout_recursive() { # {{{1
    # """
    # Checkout to a different branch on multiple git repos.
    # @note Updated 2021-09-21.
    # """
    local branch default_branch dir dirs git origin pos repo repos sort
    branch=''
    origin=''
    pos=()
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--branch='*)
                branch="${1#*=}"
                shift 1
                ;;
            '--branch')
                branch="${2:?}"
                shift 2
                ;;
            '--origin='*)
                origin="${1#*=}"
                shift 1
                ;;
            '--origin')
                origin="${2:?}"
                shift 2
                ;;
            # Other ------------------------------------------------------------
            '-'*)
                koopa::invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    dirs=("$@")
    koopa::is_array_empty "${dirs[@]}" && dirs[0]='.'
    git="$(koopa::locate_git)"
    sort="$(koopa::locate_sort)"
    for dir in "${dirs[@]}"
    do
        dir="$(koopa::realpath "$dir")"
        readarray -t repos <<< "$( \
            koopa::find \
                --glob='.git' \
                --max-depth=3 \
                --min-depth=2 \
                --prefix="$dir" \
            | "$sort" \
        )"
        if ! koopa::is_array_non_empty "${repos[@]:-}"
        then
            koopa::stop "Failed to detect any repos in '${dir}'."
        fi
        koopa::h1 "Checking out ${#repos[@]} repos in '${dir}'."
        for repo in "${repos[@]}"
        do
            repo="$(koopa::dirname "$repo")"
            koopa::h2 "$repo"
            (
                koopa::cd "$repo"
                default_branch="$(koopa::git_default_branch)"
                [[ -z "$branch" ]] && branch="$default_branch"
                if [[ -n "$origin" ]]
                then
                    "$git" fetch --all
                    if [[ "$branch" != "$default_branch" ]]
                    then
                        "$git" checkout "$default_branch"
                        "$git" branch -D "$branch" || true
                    fi
                    "$git" checkout -b "$branch" "$origin"
                else
                    "$git" checkout "$branch"
                fi
                "$git" branch -vv
            )
        done
    done
    return 0
}

koopa::git_clone() { # {{{1
    # """
    # Quietly clone a git repository.
    # @note Updated 2021-09-21.
    # """
    local branch git git_args pos repo target
    koopa::assert_has_args_ge "$#" 2
    branch=''
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--branch='*)
                branch="${1#*=}"
                shift 1
                ;;
            '--branch')
                branch="${2:?}"
                shift 2
                ;;
            # Other ------------------------------------------------------------
            '-'*)
                koopa::invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    koopa::assert_has_args_eq "$#" 2
    repo="${1:?}"
    target="${2:?}"
    if [[ -d "$target" ]]
    then
        koopa::alert_note "Repo already cloned: '${target}'."
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
    git="$(koopa::locate_git)"
    git_args=()
    if [[ -n "$branch" ]]
    then
        git_args+=(
            '-b' "$branch"
        )
    fi
    git_args+=(
        '--depth' 1
        '--quiet'
        '--recursive'
    )
    "$git" clone "${git_args[@]}" "$repo" "$target"
    return 0
}

koopa::git_default_branch() { # {{{1
    # """
    # Default branch of Git repository.
    # @note Updated 2021-05-23.
    #
    # Alternate approach:
    # > x="$( \
    # >     git symbolic-ref "refs/remotes/${remote}/HEAD" \
    # >         | sed "s@^refs/remotes/${remote}/@@" \
    # > )"
    #
    # @seealso
    # - https://stackoverflow.com/questions/28666357
    # """
    local git grep remote sed x
    koopa::assert_has_no_args "$#"
    koopa::is_git_repo || return 1
    remote='origin'
    git="$(koopa::locate_git)"
    grep="$(koopa::locate_grep)"
    sed="$(koopa::locate_sed)"
    x="$( \
        "$git" remote show "$remote" \
            | "$grep" 'HEAD branch' \
            | "$sed" 's/.*: //' \
    )"
    [[ -n "$x" ]] || return 1
    koopa::print "$x"
    return 0
}

koopa::git_init_remote() { # {{{1
    # """
    # Initialize a remote Git repository.
    # @note Updated 2021-09-21.
    # """
    local branch git origin
    branch='main'
    origin='origin'
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--branch='*)
                branch="${1#*=}"
                shift 1
                ;;
            '--branch')
                branch="${2:?}"
                shift 2
                ;;
            '--origin='*)
                origin="${1#*=}"
                shift 1
                ;;
            '--origin')
                origin="${2:?}"
                shift 2
                ;;
            # Other ------------------------------------------------------------
            *)
                koopa::invalid_arg "$1"
                ;;
        esac
    done
    koopa::assert_is_set 'branch' 'origin'
    git="$(koopa::locate_git)"
    "$git" init
    "$git" remote add "$origin" "$origin"
    "$git" remote -vv
    "$git" fetch --all
    koopa::alert "Checking out '${origin}/${branch}' branch."
    "$git" branch --set-upstream-to="${origin}/${branch}" "$branch"
    "$git" pull "$origin" "$branch" --allow-unrelated-histories
    "$git" status
    return 0
}

koopa::git_last_commit_local() { # {{{1
    # """
    # Last git commit of local repository.
    # @note Updated 2021-05-25.
    #
    # Alternate:
    # Can use '%h' for abbreviated commit ID.
    # > git log --format="%H" -n 1
    # """
    local git x
    koopa::assert_has_no_args "$#"
    koopa::is_git_repo || return 1
    git="$(koopa::locate_git)"
    x="$("$git" rev-parse HEAD 2>/dev/null || true)"
    [[ -n "$x" ]] || return 1
    koopa::print "$x"
}

koopa::git_last_commit_remote() { # {{{1
    # """
    # Last git commit of remote repository.
    # @note Updated 2021-05-25.
    # """
    local git url x
    koopa::assert_has_args "$#"
    url="${1:?}"
    koopa::assert_is_git_repo
    git="$(koopa::locate_git)"
    x="$("$git" ls-remote "$url" 'HEAD' 2>/dev/null || true)"
    [[ -n "$x" ]] || return 1
    koopa::print "$x"
}

koopa::git_rename_master_to_main() { # {{{1
    # """
    # Rename default branch from "master" to "main".
    # @note Updated 2021-05-25.
    # """
    local git new old origin
    koopa::assert_has_no_args "$#"
    koopa::assert_is_git_repo
    git="$(koopa::locate_git)"
    origin='origin'
    old='master'
    new='main'
    "$git" branch -m "$old" "$new"
    "$git" fetch "$origin"
    "$git" branch -u "${origin}/${new}" "$new"
    "$git" remote set-head "$origin" -a
    return 0
}

koopa::git_pull() { # {{{1
    # """
    # Pull (update) a git repository.
    # @note Updated 2021-05-25.
    #
    # Can quiet down with 'git submodule --quiet' here.
    # Note that git checkout, fetch, and pull also support '--quiet'.
    #
    # @seealso
    # - https://git-scm.com/docs/git-submodule/2.10.2
    # """
    local branch git
    branch=''
    [[ "$#" -gt 0 ]] && branch="${*: -1}"
    koopa::assert_is_git_repo
    git="$(koopa::locate_git)"
    koopa::alert "Pulling repo at '${PWD:?}'."
    "$git" fetch --all
    "$git" pull "$@"
    if [[ -s '.gitmodules' ]]
    then
        koopa::git_submodule_init
        "$git" submodule --quiet update --init --recursive
        "$git" submodule --quiet foreach --recursive \
            "$git" fetch --all --quiet
        if [[ -n "$branch" ]]
        then
            "$git" submodule --quiet foreach --recursive \
                "$git" checkout "$branch" --quiet
            "$git" submodule --quiet foreach --recursive \
                "$git" pull "$@"
        fi
    fi
    return 0
}

koopa::git_pull_recursive() { # {{{1
    # """
    # Pull multiple Git repositories recursively.
    # @note Updated 2021-05-25.
    # """
    local dir dirs git repo repos sort
    dirs=("$@")
    koopa::is_array_empty "${dirs[@]}" && dirs[0]='.'
    git="$(koopa::locate_git)"
    sort="$(koopa::locate_sort)"
    for dir in "${dirs[@]}"
    do
        dir="$(koopa::realpath "$dir")"
        readarray -t repos <<< "$( \
            koopa::find \
                --glob='.git' \
                --max-depth=3 \
                --min-depth=2 \
                --prefix="$dir" \
            | "$sort" \
        )"
        if ! koopa::is_array_non_empty "${repos[@]:-}"
        then
            koopa::stop "Failed to detect any git repos in '${dir}'."
        fi
        koopa::h1 "Pulling ${#repos[@]} git repos in '${dir}'."
        for repo in "${repos[@]}"
        do
            repo="$(koopa::dirname "$repo")"
            koopa::h2 "$repo"
            (
                koopa::cd "$repo"
                "$git" fetch --all
                "$git" pull --all
                "$git" status
            )
        done
    done
    return 0
}

koopa::git_push_recursive() { # {{{1
    # """
    # Push multiple Git repositories recursively.
    # @note Updated 2021-05-25.
    # """
    local dir dirs git repo repos sort
    dirs=("$@")
    koopa::is_array_empty "${dirs[@]}" && dirs[0]='.'
    git="$(koopa::locate_git)"
    sort="$(koopa::locate_sort)"
    for dir in "${dirs[@]}"
    do
        dir="$(koopa::realpath "$dir")"
        # Using '-L' flag here in case git dir is a symlink.
        readarray -t repos <<< "$( \
            koopa::find \
                --glob='.git' \
                --max-depth=3 \
                --min-depth=2 \
                --prefix="$dir" \
            | "$sort" \
        )"
        if ! koopa::is_array_non_empty "${repos[@]:-}"
        then
            koopa::stop 'Failed to detect any git repos.'
        fi
        koopa::h1 "Pushing ${#repos[@]} git repos in '${dir}'."
        for repo in "${repos[@]}"
        do
            repo="$(koopa::dirname "$repo")"
            koopa::h2 "$repo"
            (
                koopa::cd "$repo"
                "$git" push
            )
        done
    done
    return 0
}

koopa::git_push_submodules() { # {{{1
    # """
    # Push Git submodules.
    # @note Updated 2021-05-25.
    # """
    local dir dirs git
    dirs=("$@")
    koopa::is_array_empty "${dirs[@]}" && dirs[0]='.'
    git="$(koopa::locate_git)"
    for dir in "${dirs[@]}"
    do
        (
            koopa::cd "$dir"
            "$git" submodule update --remote --merge
            "$git" commit -m 'Update submodules.'
            "$git" push
        )
    done
    return 0
}

koopa::git_remote_url() { # {{{1
    # """
    # Return the Git remote URL for origin.
    # @note Updated 2021-05-25.
    # """
    local git x
    koopa::assert_has_no_args "$#"
    koopa::assert_is_git_repo
    git="$(koopa::locate_git)"
    x="$("$git" config --get 'remote.origin.url' || true)"
    [[ -n "$x" ]] || return 1
    koopa::print "$x"
    return 0
}

koopa::git_reset() { # {{{1
    # """
    # Clean and reset a git repo and its submodules.
    # @note Updated 2021-05-25.
    #
    # Note extra '-f' flag in 'git clean' step, which handles nested '.git'
    # directories better.
    #
    # See also:
    # https://gist.github.com/nicktoumpelis/11214362
    # """
    local git
    koopa::assert_has_no_args "$#"
    koopa::assert_is_git_repo
    git="$(koopa::locate_git)"
    koopa::alert "Resetting repo at '${PWD:?}'."
    "$git" clean -dffx
    if [[ -s '.gitmodules' ]]
    then
        koopa::git_submodule_init
        "$git" submodule --quiet foreach --recursive \
            "$git" clean -dffx
        "$git" reset --hard --quiet
        "$git" submodule --quiet foreach --recursive \
            "$git" reset --hard --quiet
    fi
    return 0
}

koopa::git_reset_fork_to_upstream() { # {{{1
    # """
    # Reset Git fork to upstream.
    # @note Updated 2021-05-25.
    # """
    local branch dir dirs git
    dirs=("$@")
    koopa::is_array_empty "${dirs[@]}" && dirs[0]='.'
    git="$(koopa::locate_git)"
    for dir in "${dirs[@]}"
    do
        (
            koopa::cd "$dir"
            branch="$(koopa::git_default_branch)"
            "$git" checkout "$branch"
            "$git" fetch 'upstream'
            "$git" reset --hard "upstream/${branch}"
            "$git" push 'origin' "$branch" --force
        )
    done
    return 0
}

koopa::git_rm_submodule() { # {{{1
    # """
    # Remove a git submodule.
    # @note Updated 2021-05-25.
    #
    # @seealso
    # - https://stackoverflow.com/questions/1260748/
    # - https://gist.github.com/myusuf3/7f645819ded92bda6677
    # """
    local git module
    koopa::assert_has_args "$#"
    koopa::assert_is_git_repo
    git="$(koopa::locate_git)"
    for module in "$@"
    do
        # Remove the submodule entry from '.git/config'.
        "$git" submodule deinit -f "$module"
        # Remove the submodule directory from the superproject's '.git/modules'
        # directory.
        koopa::rm ".git/modules/${module}"
        # Remove the entry in '.gitmodules' and remove the submodule directory
        # located at 'path/to/submodule'.
        "$git" rm -f "$module"
        # Update gitmodules file and commit.
        "$git" add '.gitmodules'
        "$git" commit -m "Removed submodule '${module}'."
    done
    return 0
}

koopa::git_rm_untracked() { # {{{1
    # """
    # Remove untracked files from git repo.
    # @note Updated 2021-05-25.
    # """
    local git
    koopa::assert_has_no_args "$#"
    koopa::assert_is_git_repo
    git="$(koopa::locate_git)"
    koopa::assert_is_installed 'git'
    "$git" clean -dfx
    return 0
}

koopa::git_set_remote_url() { # {{{1
    # """
    # Set (or change) the remote URL of a git repo.
    # @note Updated 2021-05-25.
    # """
    local git origin url
    koopa::assert_has_args_eq "$#" 1
    koopa::assert_is_git_repo
    git="$(koopa::locate_git)"
    url="${1:?}"
    origin='origin'
    "$git" remote set-url "$origin" "$url"
    return 0
}

koopa::git_status_recursive() { # {{{1
    # """
    # Get the status of multiple Git repos recursively.
    # @note Updated 2021-05-25.
    # """
    local dir dirs git repo repos
    dirs=("$@")
    koopa::is_array_empty "${dirs[@]}" && dirs[0]='.'
    git="$(koopa::locate_git)"
    sort="$(koopa::locate_sort)"
    for dir in "${dirs[@]}"
    do
        dir="$(koopa::realpath "$dir")"
        # Using '-L' flag here in case git dir is a symlink.
        readarray -t repos <<< "$( \
            koopa::find \
                --glob='.git' \
                --max-depth=3 \
                --min-depth=2 \
                --prefix="$dir" \
            | "$sort" \
        )"
        if ! koopa::is_array_non_empty "${repos[@]:-}"
        then
            koopa::stop 'Failed to detect any Git repos.'
        fi
        koopa::h1 "Checking status of ${#repos[@]} repos in '${dir}'."
        for repo in "${repos[@]}"
        do
            repo="$(dirname "$repo")"
            koopa::h2 "$repo"
            (
                koopa::cd "$repo"
                "$git" status
            )
        done
    done
    return 0
}

koopa::git_submodule_init() { # {{{1
    # """
    # Initialize git submodules.
    # @note Updated 2021-05-25.
    # """
    local array cut git lines string target target_key url url_key
    koopa::assert_has_no_args "$#"
    koopa::assert_is_git_repo
    koopa::assert_is_nonzero_file '.gitmodules'
    cut="$(koopa::locate_cut)"
    git="$(koopa::locate_git)"
    koopa::alert "Initializing submodules in '${PWD:?}'."
    "$git" submodule init
    lines="$( \
        "$git" config \
            -f '.gitmodules' \
            --get-regexp '^submodule\..*\.path$' \
    )"
    readarray -t array <<< "$lines"
    if ! koopa::is_array_non_empty "${array[@]:-}"
    then
        koopa::stop "Failed to detect submodules in '${PWD}'."
    fi
    for string in "${array[@]}"
    do
        target_key="$( \
            koopa::print "$string" \
            | "$cut" -d ' ' -f 1 \
        )"
        target="$( \
            koopa::print "$string" \
            | "$cut" -d ' ' -f 2 \
        )"
        url_key="${target_key//\.path/.url}"
        url="$( \
            "$git" config \
                -f '.gitmodules' \
                --get "$url_key" \
        )"
        koopa::dl "$target" "$url"
        if [[ ! -d "$target" ]]
        then
            "$git" submodule add --force "$url" "$target" > /dev/null
        fi
    done
    return 0
}
