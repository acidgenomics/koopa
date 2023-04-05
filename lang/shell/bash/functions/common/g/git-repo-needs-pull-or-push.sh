#!/usr/bin/env bash

# FIXME Need to rethink this approach?

koopa_git_repo_needs_pull_or_push() {
    # """
    # Does the current git repo need a pull or push?
    # @note Updated 2023-03-12.
    #
    # This will return an expected fatal warning when no upstream exists.
    # We're handling this case by piping errors to '/dev/null'.
    # """
    local app prefix
    koopa_assert_has_args "$#"
    local -A app
    app['git']="$(koopa_locate_git)"
    [[ -x "${app['git']}" ]] || exit 1
    (
        for prefix in "$@"
        do
            local dict
            local -A dict
            dict['prefix']="$prefix"
            koopa_cd "${dict['prefix']}"
            dict['rev1']="$("${app['git']}" rev-parse 'HEAD' 2>/dev/null)"
            dict['rev2']="$("${app['git']}" rev-parse '@{u}' 2>/dev/null)"
            [[ "${dict['rev1']}" != "${dict['rev2']}" ]] && return 0
        done
        return 1
    )
}
