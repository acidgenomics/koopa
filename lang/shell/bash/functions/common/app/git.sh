#!/usr/bin/env bash

koopa_git_checkout_recursive() { # {{{1
    # """
    # Checkout to a different branch on multiple git repos.
    # @note Updated 2021-11-23.
    # """
    local app dict dirs pos
    declare -A app=(
        [git]="$(koopa_locate_git)"
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
                koopa_invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    dirs=("$@")
    koopa_is_array_empty "${dirs[@]}" && dirs[0]="${PWD:?}"
    koopa_assert_is_dir "${dirs[@]}"
    # Using a single subshell here to avoid performance hit during looping.
    # This single subshell is necessary so we don't change working directory.
    (
        local dir
        for dir in "${dirs[@]}"
        do
            local repo repos
            dir="$(koopa_realpath "$dir")"
            readarray -t repos <<< "$( \
                koopa_find \
                    --max-depth=3 \
                    --min-depth=2 \
                    --pattern='.git' \
                    --prefix="$dir" \
                    --sort \
            )"
            if koopa_is_array_empty "${repos[@]:-}"
            then
                koopa_stop "Failed to detect any repos in '${dir}'."
            fi
            koopa_h1 "Checking out ${#repos[@]} repos in '${dir}'."
            for repo in "${repos[@]}"
            do
                local dict2
                declare -A dict2
                koopa_h2 "$repo"
                koopa_cd "$repo"
                dict2[branch]="${dict[branch]}"
                dict2[default_branch]="$(koopa_git_default_branch)"
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

koopa_git_clone() { # {{{1
    # """
    # Quietly clone a git repository.
    # @note Updated 2022-01-18.
    # """
    local app clone_args dict pos
    koopa_assert_has_args_ge "$#" 2
    declare -A app=(
        [git]="$(koopa_locate_git)"
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
                koopa_invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    koopa_assert_has_args_ge "$#" 2
    while [[ "$#" -ge 2 ]]
    do
        local dict2
        declare -A dict2=(
            [url]="${1:?}"
            [prefix]="${2:?}"
        )
        if [[ -d "${dict2[prefix]}" ]]
        then
            koopa_rm "${dict2[prefix]}"
        fi
        # Check if user has sufficient permissions.
        if koopa_str_detect_fixed \
            --string="${dict2[url]}" \
            --pattern='git@github.com'
        then
            koopa_assert_is_github_ssh_enabled
        elif koopa_str_detect_fixed \
            --string="${dict2[url]}" \
            --pattern='git@gitlab.com'
        then
            koopa_assert_is_gitlab_ssh_enabled
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

koopa_git_default_branch() { # {{{1
    # """
    # Default branch of Git repository.
    # @note Updated 2022-02-23.
    #
    # Alternate approach:
    # > x="$( \
    # >     "${app[git]}" symbolic-ref "refs/remotes/${remote}/HEAD" \
    # >         | "${app[sed]}" "s@^refs/remotes/${remote}/@@" \
    # > )"
    #
    # @seealso
    # - https://stackoverflow.com/questions/28666357
    #
    # @examples
    # > koopa_git_default_branch "${HOME}/git/monorepo"
    # # main
    # """
    local app dict repos
    declare -A app=(
        [git]="$(koopa_locate_git)"
        [sed]="$(koopa_locate_sed)"
    )
    declare -A dict=(
        [remote]='origin'
    )
    repos=("$@")
    koopa_is_array_empty "${repos[@]}" && repos[0]="${PWD:?}"
    koopa_assert_is_dir "${repos[@]}"
    # Using a single subshell here to avoid performance hit during looping.
    # This single subshell is necessary so we don't change working directory.
    (
        local repo
        for repo in "${repos[@]}"
        do
            local x
            koopa_cd "$repo"
            koopa_is_git_repo || return 1
            x="$( \
                "${app[git]}" remote show "${dict[remote]}" \
                    | koopa_grep --pattern='HEAD branch' \
                    | "${app[sed]}" 's/.*: //' \
            )"
            [[ -n "$x" ]] || return 1
            koopa_print "$x"
        done
    )
    return 0
}

koopa_git_last_commit_local() { # {{{1
    # """
    # Last git commit of local repository.
    # @note Updated 2021-11-23.
    #
    # Alternate approach:
    # Can use '%h' for abbreviated commit ID.
    # > git log --format="%H" -n 1
    #
    # @examples
    # > koopa_git_last_commit_local "${HOME}/git/monorepo"
    # # 9b7217c27858dd7ebffdf5a8ba66a6ea56ac5e1d
    # """
    local app dict repos
    declare -A app=(
        [git]="$(koopa_locate_git)"
    )
    declare -A dict=(
        [ref]='HEAD'
    )
    repos=("$@")
    koopa_is_array_empty "${repos[@]}" && repos[0]="${PWD:?}"
    koopa_assert_is_dir "${repos[@]}"
    # Using a single subshell here to avoid performance hit during looping.
    # This single subshell is necessary so we don't change working directory.
    (
        local repo
        for repo in "${repos[@]}"
        do
            local x
            koopa_cd "$repo"
            koopa_is_git_repo || return 1
            x="$("${app[git]}" rev-parse "${dict[ref]}" 2>/dev/null || true)"
            [[ -n "$x" ]] || return 1
            koopa_print "$x"
        done
    )
    return 0
}

koopa_git_last_commit_remote() { # {{{1
    # """
    # Last git commit of remote repository.
    # @note Updated 2021-11-23.
    #
    # @examples
    # > url='https://github.com/acidgenomics/koopa.git'
    # > koopa_git_last_commit_remote "$url"
    # # 73f50603e00c1c7c809a10b6187b40066b8a4e4d
    #
    # @seealso
    # > git ls-remote --help
    # """
    local app dict url
    koopa_assert_has_args "$#"
    declare -A app=(
        [awk]="$(koopa_locate_awk)"
        [git]="$(koopa_locate_git)"
        [head]="$(koopa_locate_head)"
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
        koopa_print "$x"
    done
    return 0
}

koopa_git_latest_tag() { # {{{1
    # """
    # Latest tag of a local git repo.
    # @note Updated 2022-02-03.
    #
    # @examples
    # > koopa_git_latest_tag '/opt/koopa'
    # # v0.12.1
    # """
    local app repos
    declare -A app=(
        [git]="$(koopa_locate_git)"
    )
    repos=("$@")
    koopa_is_array_empty "${repos[@]}" && repos[0]="${PWD:?}"
    koopa_assert_is_dir "${repos[@]}"
    # Using a single subshell here to avoid performance hit during looping.
    # This single subshell is necessary so we don't change working directory.
    (
        local repo
        for repo in "${repos[@]}"
        do
            local rev tag
            koopa_cd "$repo"
            koopa_is_git_repo || return 1
            rev="$("${app[git]}" rev-list --tags --max-count=1)"
            tag="$("${app[git]}" describe --tags "$rev")"
            [[ -n "$tag" ]] || return 1
            koopa_print "$tag"
        done
    )
    return 0
}

koopa_git_pull() { # {{{1
    # """
    # Pull (update) a git repository.
    # @note Updated 2021-11-24.
    #
    # Can quiet down with 'git submodule --quiet' here.
    # Note that git checkout, fetch, and pull also support '--quiet'.
    #
    # Potentially useful approach for submodules:
    # > git submodule update --init --merge --remote
    #
    # @seealso
    # - https://git-scm.com/docs/git-submodule/2.10.2
    # """
    local app repos
    declare -A app=(
        [git]="$(koopa_locate_git)"
    )
    repos=("$@")
    koopa_assert_is_dir "${repos[@]}"
    # Using a single subshell here to avoid performance hit during looping.
    # This single subshell is necessary so we don't change working directory.
    (
        for repo in "${repos[@]}"
        do
            repo="$(koopa_realpath "$repo")"
            koopa_alert "Pulling repo at '${repo}'."
            koopa_cd "$repo"
            koopa_assert_is_git_repo
            "${app[git]}" fetch --all --quiet
            "${app[git]}" pull --all --no-rebase --recurse-submodules
        done
    )
    return 0
}

koopa_git_pull_recursive() { # {{{1
    # """
    # Pull multiple Git repositories recursively.
    # @note Updated 2022-02-11.
    # """
    local app dirs
    declare -A app=(
        [git]="$(koopa_locate_git)"
    )
    dirs=("$@")
    koopa_is_array_empty "${dirs[@]}" && dirs[0]="${PWD:?}"
    koopa_assert_is_dir "${dirs[@]}"
    # Using a single subshell here to avoid performance hit during looping.
    # This single subshell is necessary so we don't change working directory.
    (
        local dir
        for dir in "${dirs[@]}"
        do
            local repo repos
            dir="$(koopa_realpath "$dir")"
            readarray -t repos <<< "$( \
                koopa_find \
                    --max-depth=3 \
                    --min-depth=2 \
                    --pattern='.git' \
                    --prefix="$dir" \
                    --sort \
            )"
            if koopa_is_array_empty "${repos[@]:-}"
            then
                koopa_stop "Failed to detect any git repos in '${dir}'."
            fi
            koopa_h1 "$(koopa_ngettext \
                --prefix='Pulling ' \
                --num="${#repos[@]}" \
                --msg1='repo' \
                --msg2='repos' \
                --suffix=" in '${dir}'." \
            )"
            for repo in "${repos[@]}"
            do
                koopa_h2 "$repo"
                koopa_cd "$repo"
                "${app[git]}" fetch --all
                "${app[git]}" pull --all
                "${app[git]}" status
            done
        done
    )
    return 0
}

koopa_git_push_recursive() { # {{{1
    # """
    # Push multiple Git repositories recursively.
    # @note Updated 2021-11-23.
    # """
    local app dirs
    declare -A app=(
        [git]="$(koopa_locate_git)"
    )
    dirs=("$@")
    koopa_is_array_empty "${dirs[@]}" && dirs[0]="${PWD:?}"
    koopa_assert_is_dir "${dirs[@]}"
    # Using a single subshell here to avoid performance hit during looping.
    # This single subshell is necessary so we don't change working directory.
    (
        local dir
        for dir in "${dirs[@]}"
        do
            local repo repos
            dir="$(koopa_realpath "$dir")"
            readarray -t repos <<< "$( \
                koopa_find \
                    --max-depth=3 \
                    --min-depth=2 \
                    --pattern='.git' \
                    --prefix="$dir" \
                    --sort \
            )"
            if koopa_is_array_empty "${repos[@]:-}"
            then
                koopa_stop "Failed to detect any git repos in '${dir}'."
            fi
            koopa_h1 "$(koopa_ngettext \
                --prefix='Pushing ' \
                --num="${#repos[@]}" \
                --msg1='repo' \
                --msg2='repos' \
                --suffix=" in '${dir}'." \
            )"
            for repo in "${repos[@]}"
            do
                koopa_h2 "$repo"
                koopa_cd "$repo"
                "${app[git]}" push
            done
        done
    )
    return 0
}

koopa_git_push_submodules() { # {{{1
    # """
    # Push Git submodules.
    # @note Updated 2021-11-23.
    # """
    local app repos
    declare -A app=(
        [git]="$(koopa_locate_git)"
    )
    repos=("$@")
    koopa_is_array_empty "${repos[@]}" && repos[0]="${PWD:?}"
    koopa_assert_is_dir "${repos[@]}"
    # Using a single subshell here to avoid performance hit during looping.
    # This single subshell is necessary so we don't change working directory.
    (
        local repo
        for repo in "${repos[@]}"
        do
            koopa_cd "$repo"
            "${app[git]}" submodule update --remote --merge
            "${app[git]}" commit -m 'Update submodules.'
            "${app[git]}" push
        done
    )
    return 0
}

koopa_git_remote_url() { # {{{1
    # """
    # Return the Git remote URL for origin.
    # @note Updated 2021-11-23.
    #
    # @examples
    # > koopa_git_remote_url '/opt/koopa'
    # # https://github.com/acidgenomics/koopa.git
    # """
    local app repos
    declare -A app=(
        [git]="$(koopa_locate_git)"
    )
    repos=("$@")
    koopa_is_array_empty "${repos[@]}" && repos[0]="${PWD:?}"
    koopa_assert_is_dir "${repos[@]}"
    # Using a single subshell here to avoid performance hit during looping.
    # This single subshell is necessary so we don't change working directory.
    (
        local repo
        for repo in "${repos[@]}"
        do
            local x
            koopa_cd "$repo"
            koopa_is_git_repo || return 1
            x="$("${app[git]}" config --get 'remote.origin.url' || true)"
            [[ -n "$x" ]] || return 1
            koopa_print "$x"
        done
    )
    return 0
}

koopa_git_rename_master_to_main() { # {{{1
    # """
    # Rename default branch from "master" to "main".
    # @note Updated 2022-03-03.
    #
    # @seealso
    # - https://hackernoon.com/how-to-rename-your-git-repositories-
    #     from-master-to-main-6i1u3wsu
    # - https://www.hanselman.com/blog/easily-rename-your-git-default-branch-
    #     from-master-to-main
    # - https://www.git-tower.com/learn/git/faq/git-rename-master-to-main
    #
    # @examples
    # > koopa_git_rename_master_to_main "${HOME}/git/example"
    # """
    local app dict repos
    declare -A app=(
        [git]="$(koopa_locate_git)"
    )
    declare -A dict=(
        [origin]='origin'
        [old_branch]='master'
        [new_branch]='main'
    )
    repos=("$@")
    koopa_is_array_empty "${repos[@]}" && repos[0]="${PWD:?}"
    koopa_assert_is_dir "${repos[@]}"
    # Using a single subshell here to avoid performance hit during looping.
    # This single subshell is necessary so we don't change working directory.
    (
        local repo
        for repo in "${repos[@]}"
        do
            koopa_cd "$repo"
            koopa_assert_is_git_repo
            # Switch to the old branch.
            "${app[git]}" switch "${dict[old_branch]}"
            # Rename (move) to the new branch.
            "${app[git]}" branch --move \
                "${dict[old_branch]}" \
                "${dict[new_branch]}"
            # Switch to the new branch.
            "${app[git]}" switch "${dict[new_branch]}"
            # Get the latest comments (and branches) from the remote.
            "${app[git]}" fetch --all --prune "${dict[origin]}"
            # Remove the existing tracking connection.
            "${app[git]}" branch --unset-upstream
            # Create a new tracking connection.
            "${app[git]}" branch \
                --set-upstream-to="${dict[origin]}/${dict[new_branch]}" \
                "${dict[new_branch]}"
            # Push the renamed branch to remote.
            "${app[git]}" push --set-upstream \
                "${dict[origin]}" \
                "${dict[new_branch]}"
            # Delete the old branch from remote. This may fail if branch is
            # protected on the remote platform.
            "${app[git]}" push \
                "${dict[origin]}" \
                --delete "${dict[old_branch]}" \
                || true
            # Set the remote HEAD.
            "${app[git]}" remote set-head "${dict[origin]}" --auto
        done
    )
    return 0
}

koopa_git_reset() { # {{{1
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
        [git]="$(koopa_locate_git)"
    )
    repos=("$@")
    koopa_is_array_empty "${repos[@]}" && repos[0]="${PWD:?}"
    koopa_assert_is_dir "${repos[@]}"
    # Using a single subshell here to avoid performance hit during looping.
    # This single subshell is necessary so we don't change working directory.
    (
        local repo
        for repo in "${repos[@]}"
        do
            repo="$(koopa_realpath "$repo")"
            koopa_alert "Resetting repo at '${repo}'."
            koopa_cd "$repo"
            koopa_assert_is_git_repo
            "${app[git]}" clean -dffx
            if [[ -s '.gitmodules' ]]
            then
                koopa_git_submodule_init
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

koopa_git_reset_fork_to_upstream() { # {{{1
    # """
    # Reset Git fork to upstream.
    # @note Updated 2021-11-23.
    # """
    local app repos
    declare -A app=(
        [git]="$(koopa_locate_git)"
    )
    repos=("$@")
    koopa_is_array_empty "${repos[@]}" && repos[0]="${PWD:?}"
    koopa_assert_is_dir "${repos[@]}"
    # Using a single subshell here to avoid performance hit during looping.
    # This single subshell is necessary so we don't change working directory.
    (
        local repo
        for repo in "${repos[@]}"
        do
            local dict
            koopa_cd "$repo"
            koopa_assert_is_git_repo
            declare -A dict=(
                [branch]="$(koopa_git_default_branch)"
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

koopa_git_rm_submodule() { # {{{1
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
    # > koopa_git_rm_submodule 'XXX' 'YYY'
    # """
    local app module
    koopa_assert_has_args "$#"
    koopa_assert_is_git_repo
    declare -A app=(
        [git]="$(koopa_locate_git)"
    )
    for module in "$@"
    do
        # Remove the submodule entry from '.git/config'.
        "${app[git]}" submodule deinit -f "$module"
        # Remove the submodule directory from the superproject's '.git/modules'
        # directory.
        koopa_rm ".git/modules/${module}"
        # Remove the entry in '.gitmodules' and remove the submodule directory
        # located at 'path/to/submodule'.
        "${app[git]}" rm -f "$module"
        # Update gitmodules file and commit.
        "${app[git]}" add '.gitmodules'
        "${app[git]}" commit -m "Removed submodule '${module}'."
    done
    return 0
}

koopa_git_rm_untracked() { # {{{1
    # """
    # Remove untracked files from git repo.
    # @note Updated 2021-11-23.
    # """
    local app repos
    declare -A app=(
        [git]="$(koopa_locate_git)"
    )
    repos=("$@")
    koopa_is_array_empty "${repos[@]}" && repos[0]="${PWD:?}"
    koopa_assert_is_dir "${repos[@]}"
    # Using a single subshell here to avoid performance hit during looping.
    # This single subshell is necessary so we don't change working directory.
    (
        local repo
        for repo in "${repos[@]}"
        do
            repo="$(koopa_realpath "$repo")"
            koopa_alert "Removing untracked files in '${repo}'."
            koopa_cd "$repo"
            koopa_assert_is_git_repo
            "${app[git]}" clean -dfx
        done
    )
    return 0
}

koopa_git_set_remote_url() { # {{{1
    # """
    # Set (or change) the remote URL of a git repo.
    # @note Updated 2021-11-18.
    #
    # @examples
    # > repo='/opt/koopa'
    # > url='https://github.com/acidgenomics/koopa.git'
    # > cd "$repo"
    # > koopa_git_set_remote_url "$url"
    # """
    local app dict
    koopa_assert_has_args_eq "$#" 1
    koopa_assert_is_git_repo
    declare -A app=(
        [git]="$(koopa_locate_git)"
    )
    declare -A dict=(
        [url]="${1:?}"
        [origin]='origin'
    )
    "${app[git]}" remote set-url "${dict[origin]}" "${dict[url]}"
    return 0
}

koopa_git_status_recursive() { # {{{1
    # """
    # Get the status of multiple Git repos recursively.
    # @note Updated 2021-11-23.
    # """
    local app dirs
    declare -A app=(
        [git]="$(koopa_locate_git)"
    )
    dirs=("$@")
    koopa_is_array_empty "${dirs[@]}" && dirs[0]="${PWD:?}"
    # Using a single subshell here to avoid performance hit during looping.
    # This single subshell is necessary so we don't change working directory.
    (
        local dir
        for dir in "${dirs[@]}"
        do
            local repo repos
            dir="$(koopa_realpath "$dir")"
            readarray -t repos <<< "$( \
                koopa_find \
                    --max-depth=3 \
                    --min-depth=2 \
                    --pattern='.git' \
                    --prefix="$dir" \
                    --sort \
            )"
            if koopa_is_array_empty "${repos[@]:-}"
            then
                koopa_stop "Failed to detect any git repos in '${dir}'."
            fi
            koopa_h1 "$(koopa_ngettext \
                --prefix='Checking status of ' \
                --num="${#repos[@]}" \
                --msg1='repo' \
                --msg2='repos' \
                --suffix=" in '${dir}'." \
            )"
            for repo in "${repos[@]}"
            do
                koopa_h2 "$repo"
                koopa_cd "$repo"
                "${app[git]}" status
            done
        done
    )
    return 0
}

koopa_git_submodule_init() { # {{{1
    # """
    # Initialize git submodules.
    # @note Updated 2021-11-23.
    # """
    local app repos
    declare -A app=(
        [awk]="$(koopa_locate_awk)"
        [git]="$(koopa_locate_git)"
    )
    repos=("$@")
    koopa_is_array_empty "${repos[@]}" && repos[0]="${PWD:?}"
    koopa_assert_is_dir "${repos[@]}"
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
            repo="$(koopa_realpath "$repo")"
            koopa_alert "Initializing submodules in '${repo}'."
            koopa_cd "$repo"
            koopa_assert_is_git_repo
            koopa_assert_is_nonzero_file "${dict[module_file]}"
            "${app[git]}" submodule init
            readarray -t lines <<< "$(
                "${app[git]}" config \
                    --file "${dict[module_file]}" \
                    --get-regexp '^submodule\..*\.path$' \
            )"
            if koopa_is_array_empty "${lines[@]:-}"
            then
                koopa_stop "Failed to detect submodules in '${repo}'."
            fi
            for string in "${lines[@]}"
            do
                local dict2
                declare -A dict2
                # shellcheck disable=SC2016
                dict2[target_key]="$( \
                    koopa_print "$string" \
                    | "${app[awk]}" '{ print $1 }' \
                )"
                # shellcheck disable=SC2016
                dict2[target]="$( \
                    koopa_print "$string" \
                    | "${app[awk]}" '{ print $2 }' \
                )"
                dict2[url_key]="${dict2[target_key]//\.path/.url}"
                dict2[url]="$( \
                    "${app[git]}" config \
                        --file "${dict[module_file]}" \
                        --get "${dict2[url_key]}" \
                )"
                koopa_dl "${dict2[target]}" "${dict2[url]}"
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
