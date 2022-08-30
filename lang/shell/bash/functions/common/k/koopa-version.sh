#!/usr/bin/env bash

koopa_koopa_version() {
    # """
    # Koopa version.
    # @note Updated 2022-08-30.
    # """
    local app dict
    declare -A app dict
    koopa_assert_has_no_args "$#"
    app['cat']="$(koopa_locate_cat --allow-missing)"
    if [[ ! -x "${app['cat']}" ]]
    then
        if [[ -x '/usr/bin/cat' ]]
        then
            app['cat']='/usr/bin/cat'
        elif [[ -x '/bin/cat' ]]
        then
            app['cat']='/bin/cat'
        fi
    fi
    [[ -x "${app['cat']}" ]] || return 1
    dict['koopa_prefix']="$(koopa_koopa_prefix)"
    dict['version_file']="${dict['koopa_prefix']}/VERSION"
    koopa_assert_is_file "${dict['version_file']}"
    dict['version']="$("${app['cat']}" "${dict['version_file']}")"
    koopa_print "${dict['version']}"
    return 0
}
