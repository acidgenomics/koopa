#!/usr/bin/env bash

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
            if koopa::is_array_empty "${repos[@]:-}"
            then
                koopa::stop "Failed to detect any git repos in '${dir}'."
            fi
            koopa::h1 "$(koopa::ngettext \
                --prefix='Checking status of ' \
                --num="${#repos[@]}" \
                --msg1='repo' \
                --msg2='repos' \
                --suffix=" in '${dir}'." \
            )"
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

