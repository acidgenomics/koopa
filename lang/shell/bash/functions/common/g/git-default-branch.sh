#!/usr/bin/env bash

koopa_git_default_branch() {
    # """
    # Default branch of Git repository.
    # @note Updated 2023-03-12.
    #
    # Alternate approach:
    # > x="$( \
    # >     "${app['git']}" symbolic-ref "refs/remotes/${remote}/HEAD" \
    # >         | "${app['sed']}" "s@^refs/remotes/${remote}/@@" \
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
    koopa_assert_has_args "$#"
    declare -A app=(
        ['git']="$(koopa_locate_git --allow-system)"
        ['sed']="$(koopa_locate_sed --allow-system)"
    )
    [[ -x "${app['git']}" ]] || return 1
    [[ -x "${app['sed']}" ]] || return 1
    declare -A dict
    dict['remote']='origin'
    repos=("$@")
    koopa_assert_is_dir "${repos[@]}"
    # Using a single subshell here to avoid performance hit during looping.
    # This single subshell is necessary so we don't change working directory.
    (
        local repo
        for repo in "${repos[@]}"
        do
            local string
            koopa_cd "$repo"
            koopa_is_git_repo "${PWD:?}" || return 1
            string="$( \
                "${app['git']}" remote show "${dict['remote']}" \
                    | koopa_grep --pattern='HEAD branch' \
                    | "${app['sed']}" 's/.*: //' \
            )"
            [[ -n "$string" ]] || return 1
            koopa_print "$string"
        done
    )
    return 0
}
