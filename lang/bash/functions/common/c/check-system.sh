#!/usr/bin/env bash

koopa_check_system() {
    # """
    # Check system.
    # @note Updated 2023-05-19.
    # """
    local -A app
    koopa_assert_has_no_args "$#"
    app['r']="$(koopa_locate_r --allow-missing)"
    if [[ ! -x "${app['r']}" ]]
    then
        koopa_stop \
            'koopa R is not installed.' \
            "Resolve with 'koopa install r'."
    fi
    koopa_check_exports || return 1
    koopa_check_disk '/' || return 1
    koopa_r_koopa 'cliCheckSystem'
    koopa_alert_success 'System passed all checks.'
    return 0
}
