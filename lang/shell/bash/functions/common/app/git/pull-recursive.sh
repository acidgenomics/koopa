#!/usr/bin/env bash

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
