#!/usr/bin/env bash

koopa_git_status_recursive() {
    # """
    # Get the status of multiple Git repos recursively.
    # @note Updated 2021-11-23.
    # """
    local app dirs
    declare -A app=(
        [git]="$(koopa_locate_git)"
    )
    [[ -x "${app['git']}" ]] || return 1
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
                "${app['git']}" status
            done
        done
    )
    return 0
}
