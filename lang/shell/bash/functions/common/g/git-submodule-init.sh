#!/usr/bin/env bash

koopa_git_submodule_init() {
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
