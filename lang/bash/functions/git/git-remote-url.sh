#!/usr/bin/env bash

_koopa_git_remote_url() {
    # """
    # Return the Git remote URL for origin.
    # @note Updated 2023-03-12.
    #
    # @examples
    # > _koopa_git_remote_url '/opt/koopa'
    # # https://github.com/acidgenomics/koopa.git
    # """
    local -A app
    app['git']="$(_koopa_locate_git --allow-system)"
    _koopa_assert_is_executable "${app[@]}"
    _koopa_assert_is_git_repo "$@"
    # Using a single subshell here to avoid performance hit during looping.
    # This single subshell is necessary so we don't change working directory.
    (
        local repo
        for repo in "$@"
        do
            local string
            _koopa_cd "$repo"
            string="$( \
                "${app['git']}" config --get 'remote.origin.url' \
                || true \
            )"
            [[ -n "$string" ]] || return 1
            _koopa_print "$string"
        done
    )
    return 0
}
