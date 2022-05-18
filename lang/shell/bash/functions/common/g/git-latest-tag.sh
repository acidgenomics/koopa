#!/usr/bin/env bash

koopa_git_latest_tag() {
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
