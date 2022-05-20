#!/usr/bin/env bash

koopa_git_default_branch() {
    # """
    # Default branch of Git repository.
    # @note Updated 2022-02-23.
    #
    # Alternate approach:
    # > x="$( \
    # >     "${app[git]}" symbolic-ref "refs/remotes/${remote}/HEAD" \
    # >         | "${app[sed]}" "s@^refs/remotes/${remote}/@@" \
    # > )"
    #
    # @seealso
    # - https://stackoverflow.com/questions/28666357
    #
    # @examples
    # > koopa_git_default_branch "${HOME}/git/monorepo"
    # # main
    # """
    local app dict repos
    declare -A app=(
        [git]="$(koopa_locate_git)"
        [sed]="$(koopa_locate_sed)"
    )
    declare -A dict=(
        [remote]='origin'
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
            x="$( \
                "${app[git]}" remote show "${dict[remote]}" \
                    | koopa_grep --pattern='HEAD branch' \
                    | "${app[sed]}" 's/.*: //' \
            )"
            [[ -n "$x" ]] || return 1
            koopa_print "$x"
        done
    )
    return 0
}
