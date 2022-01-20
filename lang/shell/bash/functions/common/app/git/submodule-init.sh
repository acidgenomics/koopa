#!/usr/bin/env bash

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
