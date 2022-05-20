#!/usr/bin/env bash

koopa_git_last_commit_local() {
    # """
    # Last git commit of local repository.
    # @note Updated 2021-11-23.
    #
    # Alternate approach:
    # Can use '%h' for abbreviated commit ID.
    # > git log --format="%H" -n 1
    #
    # @examples
    # > koopa_git_last_commit_local "${HOME}/git/monorepo"
    # # 9b7217c27858dd7ebffdf5a8ba66a6ea56ac5e1d
    # """
    local app dict repos
    declare -A app=(
        [git]="$(koopa_locate_git)"
    )
    declare -A dict=(
        [ref]='HEAD'
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
            x="$("${app[git]}" rev-parse "${dict[ref]}" 2>/dev/null || true)"
            [[ -n "$x" ]] || return 1
            koopa_print "$x"
        done
    )
    return 0
}
