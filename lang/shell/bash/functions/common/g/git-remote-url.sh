#!/usr/bin/env bash

koopa_git_remote_url() {
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
