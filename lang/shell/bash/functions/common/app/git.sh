#!/usr/bin/env bash

koopa::git_checkout_recursive() { # {{{1
    # """
    # Checkout to a different branch on multiple git repos.
    # @note Updated 2021-11-23.
    # """
    local app dict dirs pos
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
    koopa::is_array_empty "${dirs[@]}" && dirs[0]="${PWD:?}"
    koopa::assert_is_dir "${dirs[@]}"
    # Using a single subshell here to avoid performance hit during looping.
    # This single subshell is necessary so we don't change working directory.
    (
        local dir
        for dir in "${dirs[@]}"
        do
            local repo repos
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
                local dict2
                declare -A dict2
                koopa::h2 "$repo"
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
            done
        done
    )
    return 0
}

koopa::git_clone() { # {{{1
    # """
    # Quietly clone a git repository.
    # @note Updated 2021-11-23.
    # """
    local app clone_args dict pos
    koopa::assert_has_args_ge "$#" 2
    declare -A app=(
        [git]="$(koopa::locate_git)"
    )
    declare -A dict=(
        [branch]=''
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
    koopa::assert_has_args_ge "$#" 2
    while [[ "$#" -ge 2 ]]
    do
        local dict2
        declare -A dict2=(
            [url]="${1:?}"
            [prefix]="${2:?}"
        )
        if [[ -d "${dict2[prefix]}" ]]
        then
            koopa::rm "${dict2[prefix]}"
        fi
        # Check if user has sufficient permissions.
        if koopa::str_match_fixed "${dict2[url]}" 'git@github.com'
        then
            koopa::assert_is_github_ssh_enabled
        elif koopa::str_match_fixed "${dict2[url]}" 'git@gitlab.com'
        then
            koopa::assert_is_gitlab_ssh_enabled
        fi
        clone_args=()
        if [[ -n "${dict[branch]}" ]]
        then
            clone_args+=(
                '-b' "${dict[branch]}"
            )
        fi
        clone_args+=(
            '--depth' 1
            '--quiet'
            '--recursive'
            "${dict2[url]}"
            "${dict2[prefix]}"
        )
        "${app[git]}" clone "${clone_args[@]}"
        shift 2
    done
    return 0
}

koopa::git_default_branch() { # {{{1
    # """
    # Default branch of Git repository.
    # @note Updated 2021-11-23.
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
    local app dict repos
    declare -A app=(
        [git]="$(koopa::locate_git)"
        [sed]="$(koopa::locate_sed)"
    )
    declare -A dict=(
        [remote]='origin'
    )
    repos=("$@")
    koopa::is_array_empty "${repos[@]}" && repos[0]="${PWD:?}"
    koopa::assert_is_dir "${repos[@]}"
    # Using a single subshell here to avoid performance hit during looping.
    # This single subshell is necessary so we don't change working directory.
    (
        local repo
        for repo in "${repos[@]}"
        do
            local x
            koopa::cd "$repo"
            koopa::is_git_repo || return 1
            x="$( \
                "${app[git]}" remote show "${dict[remote]}" \
                    | koopa::grep 'HEAD branch' \
                    | "${app[sed]}" 's/.*: //' \
            )"
            [[ -n "$x" ]] || return 1
            koopa::print "$x"
        done
    )
    return 0
}

koopa::git_last_commit_local() { # {{{1
    # """
    # Last git commit of local repository.
    # @note Updated 2021-11-23.
    #
    # Alternate approach:
    # Can use '%h' for abbreviated commit ID.
    # > git log --format="%H" -n 1
    #
    # @examples
    # > koopa::git_last_commit_local "${HOME}/git/monorepo"
    # # 9b7217c27858dd7ebffdf5a8ba66a6ea56ac5e1d
    # """
    local app dict repos
    declare -A app=(
        [git]="$(koopa::locate_git)"
    )
    declare -A dict=(
        [ref]='HEAD'
    )
    repos=("$@")
    koopa::is_array_empty "${repos[@]}" && repos[0]="${PWD:?}"
    koopa::assert_is_dir "${repos[@]}"
    # Using a single subshell here to avoid performance hit during looping.
    # This single subshell is necessary so we don't change working directory.
    (
        local repo
        for repo in "${repos[@]}"
        do
            local x
            koopa::cd "$repo"
            koopa::is_git_repo || return 1
            x="$("${app[git]}" rev-parse "${dict[ref]}" 2>/dev/null || true)"
            [[ -n "$x" ]] || return 1
            koopa::print "$x"
        done
    )
    return 0
}

koopa::git_last_commit_remote() { # {{{1
    # """
    # Last git commit of remote repository.
    # @note Updated 2021-11-23.
    #
    # @examples
    # > url='https://github.com/acidgenomics/koopa.git'
    # > koopa::git_last_commit_remote "$url"
    # # 73f50603e00c1c7c809a10b6187b40066b8a4e4d
    #
    # @seealso
    # > git ls-remote --help
    # """
    local app dict url
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
        local x
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

# FIXME Handle attempt to pull on detached HEAD state more gracefully.
koopa::git_pull() { # {{{1
    # """
    # Pull (update) a git repository.
    # @note Updated 2021-11-23.
    #
    # Can quiet down with 'git submodule --quiet' here.
    # Note that git checkout, fetch, and pull also support '--quiet'.
    #
    # @seealso
    # - https://git-scm.com/docs/git-submodule/2.10.2
    # """
    local app dict
    declare -A app=(
        [git]="$(koopa::locate_git)"
    )
    declare -A dict=(
        [branch]=''
        [origin]='origin'
    )
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
    repos=("$@")
    koopa::is_array_empty "${repos[@]}" && repos[0]="${PWD:?}"
    koopa::assert_is_dir "${repos[@]}"
    # Using a single subshell here to avoid performance hit during looping.
    # This single subshell is necessary so we don't change working directory.
    (
        for repo in "${repos[@]}"
        do
            local dict2
            repo="$(koopa::realpath "$repo")"
            koopa::alert "Pulling repo at '${repo}'."
            koopa::cd "$repo"
            koopa::assert_is_git_repo
            declare -A dict2=(
                [branch]="${dict[branch]}"
                [origin]="${dict[origin]}"
            )
            if [[ -z "${dict2[branch]}" ]]
            then
                dict2[branch]="$(koopa::git_default_branch)"
            fi
            "${app[git]}" fetch --all
            "${app[git]}" pull "${dict2[origin]}" "${dict2[branch]}"
            if [[ -s '.gitmodules' ]]
            then
                koopa::git_submodule_init
                "${app[git]}" submodule --quiet update --init --recursive
                "${app[git]}" submodule --quiet foreach --recursive \
                    "${app[git]}" fetch --all --quiet
                if [[ -n "${dict2[branch]}" ]]
                then
                    "${app[git]}" submodule --quiet foreach --recursive \
                        "${app[git]}" checkout "${dict2[branch]}" --quiet
                    "${app[git]}" submodule --quiet foreach --recursive \
                        "${app[git]}" pull "${dict2[origin]}" "${dict2[branch]}"
                fi
            fi
        done
    )
    return 0
}

koopa::git_pull_recursive() { # {{{1
    # """
    # Pull multiple Git repositories recursively.
    # @note Updated 2021-11-23.
    # """
    local app dirs
    declare -A app=(
        [git]="$(koopa::locate_git)"
    )
    dirs=("$@")
    koopa::is_array_empty "${dirs[@]}" && dirs[0]="${PWD:?}"
    koopa::assert_is_dir "${dirs[@]}"
    # Using a single subshell here to avoid performance hit during looping.
    # This single subshell is necessary so we don't change working directory.
    (
        local dir
        for dir in "${dirs[@]}"
        do
            local repo repos str
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
            str="$(koopa::ngettext "${#repos[@]}" 'repo' 'repos')"
            koopa::h1 "Pulling ${#repos[@]} ${str} in '${dir}'."
            for repo in "${repos[@]}"
            do
                koopa::h2 "$repo"
                koopa::cd "$repo"
                "${app[git]}" fetch --all
                "${app[git]}" pull --all
                "${app[git]}" status
            done
        done
    )
    return 0
}

koopa::git_push_recursive() { # {{{1
    # """
    # Push multiple Git repositories recursively.
    # @note Updated 2021-11-23.
    # """
    local app dirs
    declare -A app=(
        [git]="$(koopa::locate_git)"
    )
    dirs=("$@")
    koopa::is_array_empty "${dirs[@]}" && dirs[0]="${PWD:?}"
    koopa::assert_is_dir "${dirs[@]}"
    # Using a single subshell here to avoid performance hit during looping.
    # This single subshell is necessary so we don't change working directory.
    (
        local dir
        for dir in "${dirs[@]}"
        do
            local repo repos str
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
            str="$(koopa::ngettext "${#repos[@]}" 'repo' 'repos')"
            koopa::h1 "Pushing ${#repos[@]} ${str} in '${dir}'."
            for repo in "${repos[@]}"
            do
                koopa::h2 "$repo"
                koopa::cd "$repo"
                "${app[git]}" push
            done
        done
    )
    return 0
}

koopa::git_push_submodules() { # {{{1
    # """
    # Push Git submodules.
    # @note Updated 2021-11-23.
    # """
    local app repos
    declare -A app=(
        [git]="$(koopa::locate_git)"
    )
    repos=("$@")
    koopa::is_array_empty "${repos[@]}" && repos[0]="${PWD:?}"
    koopa::assert_is_dir "${repos[@]}"
    # Using a single subshell here to avoid performance hit during looping.
    # This single subshell is necessary so we don't change working directory.
    (
        local repo
        for repo in "${repos[@]}"
        do
            koopa::cd "$repo"
            "${app[git]}" submodule update --remote --merge
            "${app[git]}" commit -m 'Update submodules.'
            "${app[git]}" push
        done
    )
    return 0
}

koopa::git_remote_url() { # {{{1
    # """
    # Return the Git remote URL for origin.
    # @note Updated 2021-11-23.
    #
    # @examples
    # > koopa::git_remote_url '/opt/koopa'
    # # https://github.com/acidgenomics/koopa.git
    # """
    local app repos
    declare -A app=(
        [git]="$(koopa::locate_git)"
    )
    repos=("$@")
    koopa::is_array_empty "${repos[@]}" && repos[0]="${PWD:?}"
    koopa::assert_is_dir "${repos[@]}"
    # Using a single subshell here to avoid performance hit during looping.
    # This single subshell is necessary so we don't change working directory.
    (
        local repo
        for repo in "${repos[@]}"
        do
            local x
            koopa::cd "$repo"
            koopa::is_git_repo || return 1
            x="$("${app[git]}" config --get 'remote.origin.url' || true)"
            [[ -n "$x" ]] || return 1
            koopa::print "$x"
        done
    )
    return 0
}

koopa::git_rename_master_to_main() { # {{{1
    # """
    # Rename default branch from "master" to "main".
    # @note Updated 2021-11-23.
    #
    # @examples
    # > koopa::git_rename_master_to_main "${HOME}/git/example"
    # """
    local app dict repos
    declare -A app=(
        [git]="$(koopa::locate_git)"
    )
    declare -A dict=(
        [origin]='origin'
        [old_branch]='master'
        [new_branch]='main'
    )
    repos=("$@")
    koopa::is_array_empty "${repos[@]}" && repos[0]="${PWD:?}"
    koopa::assert_is_dir "${repos[@]}"
    # Using a single subshell here to avoid performance hit during looping.
    # This single subshell is necessary so we don't change working directory.
    (
        local repo
        for repo in "${repos[@]}"
        do
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
        done
    )
    return 0
}

koopa::git_reset() { # {{{1
    # """
    # Clean and reset a git repo and its submodules.
    # @note Updated 2021-11-23.
    #
    # Note extra '-f' flag in 'git clean' step, which handles nested '.git'
    # directories better.
    #
    # See also:
    # https://gist.github.com/nicktoumpelis/11214362
    # """
    local app repos
    declare -A app=(
        [git]="$(koopa::locate_git)"
    )
    repos=("$@")
    koopa::is_array_empty "${repos[@]}" && repos[0]="${PWD:?}"
    koopa::assert_is_dir "${repos[@]}"
    # Using a single subshell here to avoid performance hit during looping.
    # This single subshell is necessary so we don't change working directory.
    (
        local repo
        for repo in "${repos[@]}"
        do
            repo="$(koopa::realpath "$repo")"
            koopa::alert "Resetting repo at '${repo}'."
            koopa::cd "$repo"
            koopa::assert_is_git_repo
            "${app[git]}" clean -dffx
            if [[ -s '.gitmodules' ]]
            then
                koopa::git_submodule_init
                "${app[git]}" submodule --quiet foreach --recursive \
                    "${app[git]}" clean -dffx
                "${app[git]}" reset --hard --quiet
                "${app[git]}" submodule --quiet foreach --recursive \
                    "${app[git]}" reset --hard --quiet
            fi
        done
    )
    return 0
}

koopa::git_reset_fork_to_upstream() { # {{{1
    # """
    # Reset Git fork to upstream.
    # @note Updated 2021-11-23.
    # """
    local app repos
    declare -A app=(
        [git]="$(koopa::locate_git)"
    )
    repos=("$@")
    koopa::is_array_empty "${repos[@]}" && repos[0]="${PWD:?}"
    koopa::assert_is_dir "${repos[@]}"
    # Using a single subshell here to avoid performance hit during looping.
    # This single subshell is necessary so we don't change working directory.
    (
        local repo
        for repo in "${repos[@]}"
        do
            local dict
            koopa::cd "$repo"
            koopa::assert_is_git_repo
            declare -A dict=(
                [branch]="$(koopa::git_default_branch)"
                [origin]='origin'
                [upstream]='upstream'
            )
            "${app[git]}" checkout "${dict[branch]}"
            "${app[git]}" fetch "${dict[upstream]}"
            "${app[git]}" reset --hard "${dict[upstream]}/${dict[branch]}"
            "${app[git]}" push "${dict[origin]}" "${dict[branch]}" --force
        done
    )
    return 0
}

koopa::git_rm_submodule() { # {{{1
    # """
    # Remove a git submodule from current repository.
    # @note Updated 2021-11-18.
    #
    # @seealso
    # - https://stackoverflow.com/questions/1260748/
    # - https://gist.github.com/myusuf3/7f645819ded92bda6677
    #
    # @examples
    # > cd "${HOME}/git/monorepo"
    # > koopa::git_rm_submodule 'XXX' 'YYY'
    # """
    local app module
    koopa::assert_has_args "$#"
    koopa::assert_is_git_repo
    declare -A app=(
        [git]="$(koopa::locate_git)"
    )
    for module in "$@"
    do
        # Remove the submodule entry from '.git/config'.
        "${app[git]}" submodule deinit -f "$module"
        # Remove the submodule directory from the superproject's '.git/modules'
        # directory.
        koopa::rm ".git/modules/${module}"
        # Remove the entry in '.gitmodules' and remove the submodule directory
        # located at 'path/to/submodule'.
        "${app[git]}" rm -f "$module"
        # Update gitmodules file and commit.
        "${app[git]}" add '.gitmodules'
        "${app[git]}" commit -m "Removed submodule '${module}'."
    done
    return 0
}

koopa::git_rm_untracked() { # {{{1
    # """
    # Remove untracked files from git repo.
    # @note Updated 2021-11-23.
    # """
    local app repos
    declare -A app=(
        [git]="$(koopa::locate_git)"
    )
    repos=("$@")
    koopa::is_array_empty "${repos[@]}" && repos[0]="${PWD:?}"
    koopa::assert_is_dir "${repos[@]}"
    # Using a single subshell here to avoid performance hit during looping.
    # This single subshell is necessary so we don't change working directory.
    (
        local repo
        for repo in "${repos[@]}"
        do
            repo="$(koopa::realpath "$repo")"
            koopa::alert "Removing untracked files in '${repo}'."
            koopa::cd "$repo"
            koopa::assert_is_git_repo
            "${app[git]}" clean -dfx
        done
    )
    return 0
}

koopa::git_set_remote_url() { # {{{1
    # """
    # Set (or change) the remote URL of a git repo.
    # @note Updated 2021-11-18.
    #
    # @examples
    # > repo='/opt/koopa'
    # > url='https://github.com/acidgenomics/koopa.git'
    # > cd "$repo"
    # > koopa::git_set_remote_url "$url"
    # """
    local app dict
    koopa::assert_has_args_eq "$#" 1
    koopa::assert_is_git_repo
    declare -A app=(
        [git]="$(koopa::locate_git)"
    )
    declare -A dict=(
        [url]="${1:?}"
        [origin]='origin'
    )
    "${app[git]}" remote set-url "${dict[origin]}" "${dict[url]}"
    return 0
}

koopa::git_status_recursive() { # {{{1
    # """
    # Get the status of multiple Git repos recursively.
    # @note Updated 2021-11-23.
    # """
    local app dirs
    declare -A app=(
        [git]="$(koopa::locate_git)"
    )
    dirs=("$@")
    koopa::is_array_empty "${dirs[@]}" && dirs[0]="${PWD:?}"
    # Using a single subshell here to avoid performance hit during looping.
    # This single subshell is necessary so we don't change working directory.
    (
        local dir
        for dir in "${dirs[@]}"
        do
            local repo repos str
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
            str="$(koopa::ngettext "${#repos[@]}" 'repo' 'repos')"
            koopa::h1 "Checking status of ${#repos[@]} ${str} in '${dir}'."
            for repo in "${repos[@]}"
            do
                koopa::h2 "$repo"
                koopa::cd "$repo"
                "${app[git]}" status
            done
        done
    )
    return 0
}

koopa::git_submodule_init() { # {{{1
    # """
    # Initialize git submodules.
    # @note Updated 2021-11-23.
    # """
    local app repos
    declare -A app=(
        [awk]="$(koopa::locate_awk)"
        [git]="$(koopa::locate_git)"
    )
    repos=("$@")
    koopa::is_array_empty "${repos[@]}" && repos[0]="${PWD:?}"
    koopa::assert_is_dir "${repos[@]}"
    # Using a single subshell here to avoid performance hit during looping.
    # This single subshell is necessary so we don't change working directory.
    (
        local repo
        for repo in "${repos[@]}"
        do
            local dict lines string
            declare -A dict=(
                [module_file]='.gitmodules'
            )
            repo="$(koopa::realpath "$repo")"
            koopa::alert "Initializing submodules in '${repo}'."
            koopa::cd "$repo"
            koopa::assert_is_git_repo
            koopa::assert_is_nonzero_file "${dict[module_file]}"
            "${app[git]}" submodule init
            readarray -t lines <<< "$(
                "${app[git]}" config \
                    --file "${dict[module_file]}" \
                    --get-regexp '^submodule\..*\.path$' \
            )"
            if ! koopa::is_array_non_empty "${lines[@]:-}"
            then
                koopa::stop "Failed to detect submodules in '${repo}'."
            fi
            for string in "${lines[@]}"
            do
                local dict2
                declare -A dict2
                # shellcheck disable=SC2016
                dict2[target_key]="$( \
                    koopa::print "$string" \
                    | "${app[awk]}" '{ print $1 }' \
                )"
                # shellcheck disable=SC2016
                dict2[target]="$( \
                    koopa::print "$string" \
                    | "${app[awk]}" '{ print $2 }' \
                )"
                dict2[url_key]="${dict2[target_key]//\.path/.url}"
                dict2[url]="$( \
                    "${app[git]}" config \
                        --file "${dict[module_file]}" \
                        --get "${dict2[url_key]}" \
                )"
                koopa::dl "${dict2[target]}" "${dict2[url]}"
                if [[ ! -d "${dict2[target]}" ]]
                then
                    "${app[git]}" submodule add --force \
                        "${dict2[url]}" "${dict2[target]}" > /dev/null
                fi
            done
        done
    )
    return 0
}
