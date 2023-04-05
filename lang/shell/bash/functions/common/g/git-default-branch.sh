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
    local app dict
    koopa_assert_has_args "$#"
    local -A app=(
        ['git']="$(koopa_locate_git --allow-system)"
        ['sed']="$(koopa_locate_sed --allow-system)"
    )
    [[ -x "${app['git']}" ]] || exit 1
    [[ -x "${app['sed']}" ]] || exit 1
    local -A dict
    dict['remote']='origin'
    koopa_assert_is_git_repo "$@"
    # Using a single subshell here to avoid performance hit during looping.
    # This single subshell is necessary so we don't change working directory.
    (
        local repo
        for repo in "$@"
        do
            local string
            koopa_cd "$repo"
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
