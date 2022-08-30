#!/usr/bin/env bash

koopa_git_default_branch() {
    # """
    # Default branch of Git repository.
    # @note Updated 2022-08-30.
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
    declare -A app=(
        ['git']="$(koopa_locate_git --allow-missing)"
        ['sed']="$(koopa_locate_sed --allow-missing)"
    )
    [[ ! -x "${app['git']}" ]] && app['git']='/usr/bin/git'
    [[ ! -x "${app['sed']}" ]] && app['sed']='/usr/bin/sed'
    [[ -x "${app['git']}" ]] || return 1
    [[ -x "${app['sed']}" ]] || return 1
    declare -A dict=(
        ['remote']='origin'
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
                "${app['git']}" remote show "${dict['remote']}" \
                    | koopa_grep --pattern='HEAD branch' \
                    | "${app['sed']}" 's/.*: //' \
            )"
            [[ -n "$x" ]] || return 1
            koopa_print "$x"
        done
    )
    return 0
}
