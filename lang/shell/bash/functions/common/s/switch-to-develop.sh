#!/usr/bin/env bash

koopa_switch_to_develop() {
    # """
    # Switch koopa install to development version.
    # @note Updated 2022-08-30.
    #
    # @seealso
    # - https://stackoverflow.com/questions/49297153/
    # """
    local app dict
    koopa_assert_has_no_args "$#"
    declare -A app=(
        ['git']="$(koopa_locate_git --allow-missing)"
    )
    [[ ! -x "${app['git']}" ]] && app['git']='/usr/bin/git'
    [[ -x "${app['git']}" ]] || return 1
    declare -A dict=(
        ['branch']='develop'
        ['origin']='origin'
        ['prefix']="$(koopa_koopa_prefix)"
    )
    koopa_alert "Switching koopa at '${dict['prefix']}' to '${dict['branch']}'."
    koopa_sys_set_permissions --recursive "${dict['prefix']}"
    (
        koopa_cd "${dict['prefix']}"
        # > "${app['git']}" fetch --unshallow || true
        # > "${app['git']}" checkout \
        # >     -B "${dict['branch']}" \
        # >     "${dict['origin']}/${dict['branch']}"
        # This approach works with shallow clone:
        "${app['git']}" remote set-branches \
            --add "${dict['origin']}" "${dict['branch']}"
        "${app['git']}" fetch "${dict['origin']}"
        "${app['git']}" checkout --track "${dict['origin']}/${dict['branch']}"
    )
    koopa_sys_set_permissions --recursive "${dict['prefix']}"
    koopa_fix_zsh_permissions
    return 0
}
