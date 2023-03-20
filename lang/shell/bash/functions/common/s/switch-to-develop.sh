#!/usr/bin/env bash

# FIXME Also set the origin to SSH instead of HTTPS.
# git remote set-url origin git@github.com:acidgenomics/koopa.git

koopa_switch_to_develop() {
    # """
    # Switch koopa install to development version.
    # @note Updated 2023-03-12.
    #
    # @seealso
    # - https://stackoverflow.com/questions/49297153/
    # """
    local app dict
    koopa_assert_has_no_args "$#"
    koopa_assert_is_owner
    declare -A app
    app['git']="$(koopa_locate_git --allow-system)"
    [[ -x "${app['git']}" ]] || return 1
    declare -A dict=(
        ['branch']='develop'
        ['origin']='origin'
        ['prefix']="$(koopa_koopa_prefix)"
        ['user']="$(koopa_user)"
    )
    koopa_alert "Switching koopa at '${dict['prefix']}' to '${dict['branch']}'."
    (
        koopa_cd "${dict['prefix']}"
        if [[ "$(koopa_git_branch "${PWD:?}")" == 'develop' ]]
        then
            koopa_alert_note "Already on 'develop' branch."
            return 0
        fi
        "${app['git']}" remote set-branches \
            --add "${dict['origin']}" "${dict['branch']}"
        "${app['git']}" fetch "${dict['origin']}"
        "${app['git']}" checkout --track "${dict['origin']}/${dict['branch']}"
    )
    koopa_zsh_compaudit_set_permissions
    return 0
}
