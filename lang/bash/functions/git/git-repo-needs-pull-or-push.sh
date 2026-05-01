#!/usr/bin/env bash

_koopa_git_repo_needs_pull_or_push() {
    # """
    # Does the current git repo need a pull or push?
    # @note Updated 2023-03-12.
    #
    # This will return an expected fatal warning when no upstream exists.
    # We're handling this case by piping errors to '/dev/null'.
    # """
    local -A app
    local prefix
    _koopa_assert_has_args "$#"
    app['git']="$(_koopa_locate_git)"
    _koopa_assert_is_executable "${app[@]}"
    (
        for prefix in "$@"
        do
            local -A dict
            dict['prefix']="$prefix"
            _koopa_cd "${dict['prefix']}"
            dict['rev1']="$("${app['git']}" rev-parse 'HEAD' 2>/dev/null)"
            dict['rev2']="$("${app['git']}" rev-parse '@{u}' 2>/dev/null)"
            [[ "${dict['rev1']}" != "${dict['rev2']}" ]] && return 0
        done
        return 1
    )
}
