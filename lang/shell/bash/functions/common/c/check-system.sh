#!/usr/bin/env bash

koopa_check_system() {
    # """
    # Check system.
    # @note Updated 2022-05-06.
    # """
    koopa_assert_has_no_args "$#"
    koopa_check_exports || return 1
    koopa_check_disk '/' || return 1
    if ! koopa_is_r_package_installed 'koopa'
    then
        koopa_install_r_koopa
    fi
    koopa_r_koopa --vanilla 'cliCheckSystem'
    koopa_alert_success 'System passed all checks.'
    return 0
}
