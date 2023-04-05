#!/usr/bin/env bash

koopa_brew_reset_core_repo() {
    # """
    # Ensure internal 'homebrew-core' repo is clean.
    # @note Updated 2023-04-04.
    # """
    local -A app dict
    koopa_assert_has_no_args "$#"
    app['brew']="$(koopa_locate_brew)"
    app['git']="$(koopa_locate_git --allow-system)"
    [[ -x "${app['brew']}" ]] || exit 1
    [[ -x "${app['git']}" ]] || exit 1
    dict['repo']='homebrew/core'
    dict['origin']='origin'
    dict['prefix']="$("${app['brew']}" --repo "${dict['repo']}")"
    koopa_assert_is_dir "${dict['prefix']}"
    (
        koopa_cd "${dict['prefix']}"
        branch="$(koopa_git_default_branch "${PWD:?}")"
        "${app['git']}" checkout -q "${dict['branch']}"
        "${app['git']}" branch -q \
            "${dict['branch']}" \
            -u "${dict['origin']}/${dict['branch']}"
        "${app['git']}" reset -q \
            --hard \
            "${dict['origin']}/${dict['branch']}"
        "${app['git']}" branch -vv
    )
    return 0
}
