#!/usr/bin/env bash

koopa::git_clone() { # {{{1
    # """
    # Quietly clone a git repository.
    # @note Updated 2022-01-18.
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
        if koopa::str_detect_fixed "${dict2[url]}" 'git@github.com'
        then
            koopa::assert_is_github_ssh_enabled
        elif koopa::str_detect_fixed "${dict2[url]}" 'git@gitlab.com'
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
