#!/usr/bin/env bash

# FIXME Rework these functions to allow direct file path support, when possible.

# FIXME shellcheck is currently returning false positive about 'branch'
# modification inside of a subshell.

# FIXME Need to add a function to detect whether git repo is detached (e.g. HEAD)
# state. In that case, koopa::git_pull should skip and inform the user.
# FIXME This is also called in 'koopa::configure_user', which needs to be adjusted.

koopa::git_checkout_recursive() { # {{{1
    # """
    # Checkout to a different branch on multiple git repos.
    # @note Updated 2021-11-18.
    # """
    local app dict dir dirs pos repo repos
    declare -A app=(
        [git]="$(koopa::locate_git)"
    )
    declare -A dict=(
        [branch]=''
        [origin]=''
    )
    pos=()
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--branch='*)
                dict[branch]="${1#*=}"
                shift 1
                ;;
            '--branch')
                dict[branch]="${2:?}"
                shift 2
                ;;
            '--origin='*)
                dict[origin]="${1#*=}"
                shift 1
                ;;
            '--origin')
                dict[origin]="${2:?}"
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
    for dir in "${dirs[@]}"
    do
        dir="$(koopa::realpath "$dir")"
        readarray -t repos <<< "$( \
            koopa::find \
                --glob='.git' \
                --max-depth=3 \
                --min-depth=2 \
                --prefix="$dir" \
                --sort \
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
                local dict2
                declare -A dict2
                koopa::cd "$repo"
                dict2[branch]="${dict[branch]}"
                dict2[default_branch]="$(koopa::git_default_branch)"
                if [[ -z "${dict2[branch]}" ]]
                then
                    dict2[branch]="${dict2[default_branch]}"
                fi
                if [[ -n "${dict[origin]}" ]]
                then
                    "${app[git]}" fetch --all
                    if [[ "${dict2[branch]}" != "${dict2[default_branch]}" ]]
                    then
                        "${app[git]}" checkout "${dict2[default_branch]}"
                        "${app[git]}" branch -D "${dict2[branch]}" || true
                    fi
                    "${app[git]}" checkout \
                        -B "${dict2[branch]}" \
                        "${dict[origin]}"
                else
                    "${app[git]}" checkout "${dict2[branch]}"
                fi
                "${app[git]}" branch -vv
            )
        done
    done
    return 0
}

# FIXME Improve parameterization, supporting multiple values...
koopa::git_clone() { # {{{1
    # """
    # Quietly clone a git repository.
    # @note Updated 2021-11-17.
    # """
    local app dict git_args pos
    koopa::assert_has_args_ge "$#" 2
    declare -A app=(
        [git]="$(koopa::locate_git)"
    )
    declare -A dict=(
        [branch]=''
    )
    git_args=()
    pos=()
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--branch='*)
                dict[branch]="${1#*=}"
                shift 1
                ;;
            '--branch')
                dict[branch]="${2:?}"
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
    dict[repo]="${1:?}"
    dict[target]="${2:?}"
    [[ -d "${dict[target]}" ]] && koopa::rm "${dict[target]}"
    # Check if user has sufficient permissions.
    if koopa::str_match_fixed "${dict[repo]}" 'git@github.com'
    then
        koopa::assert_is_github_ssh_enabled
    elif koopa::str_match_fixed "${dict[repo]}" 'git@gitlab.com'
    then
        koopa::assert_is_gitlab_ssh_enabled
    fi
    if [[ -n "${dict[branch]}" ]]
    then
        git_args+=(
            '-b' "${dict[branch]}"
        )
    fi
    git_args+=(
        '--depth' 1
        '--quiet'
        '--recursive'
    )
    "${app[git]}" clone "${git_args[@]}" "${dict[repo]}" "${dict[target]}"
    return 0
}

koopa::git_default_branch() { # {{{1
    # """
    # Default branch of Git repository.
    # @note Updated 2021-11-18.
    #
    # Alternate approach:
    # > x="$( \
    # >     git symbolic-ref "refs/remotes/${remote}/HEAD" \
    # >         | sed "s@^refs/remotes/${remote}/@@" \
    # > )"
    #
    # @seealso
    # - https://stackoverflow.com/questions/28666357
    #
    # @examples
    # > koopa::git_default_branch "${HOME}/git/monorepo"
    # # main
    # """
    local app dict repo repos x
    koopa::assert_has_args "$#"
    declare -A app=(
        [git]="$(koopa::locate_git)"
        [sed]="$(koopa::locate_sed)"
    )
    declare -A dict=(
        [remote]='origin'
    )
    repos=("$@")
    koopa::assert_is_dir "${repos[@]}"
    for repo in "${repos[@]}"
    do
        (
            koopa::cd "$repo"
            koopa::is_git_repo || return 1
            x="$( \
                "${app[git]}" remote show "${dict[remote]}" \
                    | koopa::grep 'HEAD branch' \
                    | "${app[sed]}" 's/.*: //' \
            )"
            [[ -n "$x" ]] || return 1
            koopa::print "$x"
        )
    done
    return 0
}

# FIXME Allow the user to set a path here, and switch dynamically.
# FIXME Consider allowing parameterization.
# FIXME Export this as a user-accessible command-line function.
# FIXME We need to pass in the URL here...currently too confusing.
# FIXME Need to add a working example for this.

koopa::git_init_remote() { # {{{1
    # """
    # Initialize a remote Git repository.
    # @note Updated 2021-11-18.
    # """
    local branch git origin
    koopa::assert_has_args "$#"
    declare -A app=(
        [git]="$(koopa::locate_git)"
    )
    declare -A dict=(
        [branch]='main'
        [origin]='origin'
    )

    # FIXME Rework with pos approach here.
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
    koopa::assert_has_args "$#"

    ## FIXME Rework this.
    koopa::assert_is_set 'branch' 'origin'

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
    # @note Updated 2021-11-18.
    #
    # Alternate approach:
    # Can use '%h' for abbreviated commit ID.
    # > git log --format="%H" -n 1
    #
    # @examples
    # > koopa::git_last_commit_local "${HOME}/git/monorepo"
    # # 9b7217c27858dd7ebffdf5a8ba66a6ea56ac5e1d
    # """
    local app dict repo repos x
    koopa::assert_has_args "$#"
    declare -A app=(
        [git]="$(koopa::locate_git)"
    )
    declare -A dict=(
        [ref]='HEAD'
    )
    repos=("$@")
    koopa::assert_is_dir "${repos[@]}"
    for repo in "$@"
    do
        (
            koopa::cd "$repo"
            koopa::is_git_repo || return 1
            x="$("${app[git]}" rev-parse "${dict[ref]}" 2>/dev/null || true)"
            [[ -n "$x" ]] || return 1
            koopa::print "$x"
        )
    done
    return 0
}

koopa::git_last_commit_remote() { # {{{1
    # """
    # Last git commit of remote repository.
    # @note Updated 2021-11-18.
    #
    # @examples
    # > url='https://github.com/acidgenomics/koopa.git'
    # > koopa::git_last_commit_remote "$url"
    # # 73f50603e00c1c7c809a10b6187b40066b8a4e4d
    #
    # @seealso
    # > git ls-remote --help
    # """
    local app dict url x
    koopa::assert_has_args "$#"
    declare -A app=(
        [awk]="$(koopa::locate_awk)"
        [git]="$(koopa::locate_git)"
        [head]="$(koopa::locate_head)"
    )
    declare -A dict=(
        [ref]='HEAD'
    )
    for url in "$@"
    do
        # shellcheck disable=SC2016
        x="$( \
            "${app[git]}" ls-remote --quiet "$url" "${dict[ref]}" \
            | "${app[head]}" -n 1 \
            | "${app[awk]}" '{ print $1 }' \
        )"
        [[ -n "$x" ]] || return 1
        koopa::print "$x"
    done
    return 0
}

koopa::git_rename_master_to_main() { # {{{1
    # """
    # Rename default branch from "master" to "main".
    # @note Updated 2021-11-18.
    #
    # @examples
    # > koopa::git_rename_master_to_main "${HOME}/git/example"
    # """
    local app dict repo repos
    koopa::assert_has_args "$#"
    declare -A app=(
        [git]="$(koopa::locate_git)"
    )
    declare -A dict=(
        [origin]='origin'
        [old_branch]='master'
        [new_branch]='main'
    )
    repos=("$@")
    koopa::assert_is_dir "${repos[@]}"
    for repo in "${repos[@]}"
    do
        (
            koopa::cd "$repo"
            koopa::assert_is_git_repo
            "${app[git]}" branch -m \
                "${dict[old_branch]}" \
                "${dict[new_branch]}"
            "${app[git]}" fetch "${dict[origin]}"
            "${app[git]}" branch \
                -u "${dict[origin]}/${dict[new_branch]}" \
                "${dict[new_branch]}"
            "${app[git]}" remote set-head "${dict[origin]}" -a
        )
    done
    return 0
}

# FIXME Allow the user to pull multiple repos in a single call.
# FIXME Need to allow direct file path input here.
# FIXME Rework using dict approach.
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

# FIXME Rework this.
koopa::git_pull_recursive() { # {{{1
    # """
    # Pull multiple Git repositories recursively.
    # @note Updated 2021-10-26.
    # """
    local dir dirs git repo repos
    dirs=("$@")
    koopa::is_array_empty "${dirs[@]}" && dirs[0]='.'
    git="$(koopa::locate_git)"
    for dir in "${dirs[@]}"
    do
        dir="$(koopa::realpath "$dir")"
        readarray -t repos <<< "$( \
            koopa::find \
                --glob='.git' \
                --max-depth=3 \
                --min-depth=2 \
                --prefix="$dir" \
                --sort \
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

# FIXME Rework this.
koopa::git_push_recursive() { # {{{1
    # """
    # Push multiple Git repositories recursively.
    # @note Updated 2021-10-26.
    # """
    local dir dirs git repo repos
    dirs=("$@")
    koopa::is_array_empty "${dirs[@]}" && dirs[0]='.'
    git="$(koopa::locate_git)"
    for dir in "${dirs[@]}"
    do
        dir="$(koopa::realpath "$dir")"
        readarray -t repos <<< "$( \
            koopa::find \
                --glob='.git' \
                --max-depth=3 \
                --min-depth=2 \
                --prefix="$dir" \
                --sort \
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

# FIXME Rework this.
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

# FIXME Rework this.
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

# FIXME Rework this.
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

# FIXME Rework this.
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

# FIXME Rework this.
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

# FIXME Rework this.
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

# FIXME Rework this.
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

# FIXME Rework this.
koopa::git_status_recursive() { # {{{1
    # """
    # Get the status of multiple Git repos recursively.
    # @note Updated 2021-10-26.
    # """
    local dir dirs git repo repos
    dirs=("$@")
    koopa::is_array_empty "${dirs[@]}" && dirs[0]='.'
    git="$(koopa::locate_git)"
    for dir in "${dirs[@]}"
    do
        dir="$(koopa::realpath "$dir")"
        readarray -t repos <<< "$( \
            koopa::find \
                --glob='.git' \
                --max-depth=3 \
                --min-depth=2 \
                --prefix="$dir" \
                --sort \
        )"
        if ! koopa::is_array_non_empty "${repos[@]:-}"
        then
            koopa::stop 'Failed to detect any Git repos.'
        fi
        koopa::h1 "Checking status of ${#repos[@]} repos in '${dir}'."
        for repo in "${repos[@]}"
        do
            repo="$(koopa::dirname "$repo")"
            koopa::h2 "$repo"
            (
                koopa::cd "$repo"
                "$git" status
            )
        done
    done
    return 0
}

# FIXME Rework, allowing input of multiple git repos here.
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
