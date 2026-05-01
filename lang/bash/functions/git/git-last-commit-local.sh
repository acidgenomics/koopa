#!/usr/bin/env bash

_koopa_git_last_commit_local() {
    # """
    # Last git commit of local repository.
    # @note Updated 2023-03-12.
    #
    # Alternate approach:
    # Can use '%h' for abbreviated commit identifier.
    # > git log --format="%H" -n 1
    #
    # @examples
    # > _koopa_git_last_commit_local "${HOME}/git/monorepo"
    # # 9b7217c27858dd7ebffdf5a8ba66a6ea56ac5e1d
    # """
    local -A app dict
    _koopa_assert_has_args "$#"
    app['git']="$(_koopa_locate_git --allow-system)"
    _koopa_assert_is_executable "${app[@]}"
    dict['ref']='HEAD'
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
                "${app['git']}" rev-parse "${dict['ref']}" \
                2>/dev/null \
                || true \
            )"
            [[ -n "$string" ]] || return 1
            _koopa_print "$string"
        done
    )
    return 0
}
