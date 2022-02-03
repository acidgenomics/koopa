#!/usr/bin/env bash

koopa::git_latest_tag() { # {{{1
    # """
    # Latest tag of a local git repo.
    # @note Updated 2022-02-03.
    #
    # @examples
    # > koopa::git_latest_tag '/opt/koopa'
    # # v0.12.1
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
            local rev tag
            koopa::cd "$repo"
            koopa::is_git_repo || return 1
            rev="$("${app[git]}" rev-list --tags --max-count=1)"
            tag="$("${app[git]}" describe --tags "$rev")"
            [[ -n "$tag" ]] || return 1
            koopa::print "$tag"
        done
    )
    return 0
}
