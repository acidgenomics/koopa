#!/usr/bin/env bash

_koopa_brew_reset_core_repo() {
    # """
    # Ensure internal 'homebrew-core' repo is clean.
    # @note Updated 2023-05-09.
    # """
    local -A app dict
    _koopa_assert_has_no_args "$#"
    app['brew']="$(_koopa_locate_brew)"
    app['git']="$(_koopa_locate_git --allow-system)"
    _koopa_assert_is_executable "${app[@]}"
    dict['repo']='homebrew/core'
    dict['prefix']="$("${app['brew']}" --repo "${dict['repo']}")"
    _koopa_assert_is_dir "${dict['prefix']}"
    _koopa_alert "Resetting git repo at '${dict['prefix']}'."
    (
        local -A dict2
        _koopa_cd "${dict['prefix']}"
        dict2['branch']="$(_koopa_git_default_branch "${PWD:?}")"
        dict2['origin']='origin'
        "${app['git']}" checkout -q "${dict2['branch']}"
        "${app['git']}" branch -q \
            "${dict2['branch']}" \
            -u "${dict2['origin']}/${dict2['branch']}"
        "${app['git']}" reset -q --hard \
            "${dict2['origin']}/${dict2['branch']}"
        # > "${app['git']}" branch -vv
    )
    return 0
}
