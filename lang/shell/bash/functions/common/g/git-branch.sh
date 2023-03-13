#!/usr/bin/env bash

koopa_git_branch() {
    # """
    # Current git branch name.
    # @note Updated 2023-03-12.
    #
    # Correctly handles detached 'HEAD' state.
    #
    # Approaches:
    # > git branch --show-current
    # > git name-rev --name-only 'HEAD'
    # > git rev-parse --abbrev-ref 'HEAD'
    # > git symbolic-ref --short -q 'HEAD'
    #
    # @seealso
    # - https://stackoverflow.com/questions/6245570/
    # - https://git.kernel.org/pub/scm/git/git.git/tree/contrib/completion/
    #       git-completion.bash?id=HEAD
    # """
    local app dict
    koopa_assert_has_args_eq "$#" 1
    declare -A app=(
        ['cut']="$(koopa_locate_cut --allow-system)"
        ['git']="$(koopa_locate_git --allow-system)"
        ['head']="$(koopa_locate_head --allow-system)"
    )
    [[ -x "${app['cut']}" ]] || return 1
    [[ -x "${app['git']}" ]] || return 1
    [[ -x "${app['head']}" ]] || return 1
    declare -A dict
    dict['prefix']="${1:?}"
    koopa_assert_is_git_repo "${dict['prefix']}"
    (
        local dict2
        declare -A dict2
        dict2['branch']="$("${app['git']}" branch --show-current 2>/dev/null)"
        # Keep track of detached HEAD state.
        if [[ -z "${dict2['branch']}" ]]
        then
            dict2['branch']="$( \
                "${app['git']}" branch 2>/dev/null \
                | "${app['head']}" -n 1 \
                | "${app['cut']}" -c '3-' \
            )"
        fi
        [[ -n "${dict2['branch']}" ]] || return 0
        koopa_print "${dict2['branch']}"
    )
    return 0
}
