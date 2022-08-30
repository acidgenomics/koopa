#!/usr/bin/env bash

koopa_git_commit_date() {
    # """
    # Date of last git commit.
    # @note Updated 2022-08-30.
    #
    # Alternative approach:
    # > "${app['git']}" log -1 --format='%cd'
    #
    # @examples
    # > koopa_git_last_commit_local "${HOME}/git/monorepo"
    # # 2022-08-04
    # """
    local app repos
    declare -A app=(
        ['date']="$(koopa_locate_date --allow-missing)"
        ['git']="$(koopa_locate_git --allow-missing)"
        ['xargs']="$(koopa_locate_xargs --allow-missing)"
    )
    if [[ ! -x "${app['date']}" ]]
    then
        if [[ -x '/usr/bin/date' ]]
        then
            app['date']='/usr/bin/date'
        elif [[ -x '/bin/date' ]]
        then
            app['date']='/bin/date'
        fi
    fi
    [[ ! -x "${app['git']}" ]] && app['git']='/usr/bin/git'
    [[ ! -x "${app['xargs']}" ]] && app['xargs']='/usr/bin/xargs'
    [[ -x "${app['date']}" ]] || return 1
    [[ -x "${app['git']}" ]] || return 1
    [[ -x "${app['xargs']}" ]] || return 1
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
                "${app['git']}" log -1 --format='%at' \
                    | "${app['xargs']}" -I '{}' \
                        "${app['date']}" -d '@{}' '+%Y-%m-%d' \
                    2>/dev/null || true \
            )"
            [[ -n "$x" ]] || return 1
            koopa_print "$x"
        done
    )
    return 0
}
