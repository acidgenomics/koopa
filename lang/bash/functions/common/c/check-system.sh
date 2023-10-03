#!/usr/bin/env bash

# FIXME Rework this in Python.

koopa_check_system() {
    # """
    # Check system.
    # @note Updated 2023-10-03.
    # """
    koopa_assert_has_no_args "$#"
    koopa_check_exports
    koopa_check_disk '/'
    koopa_r_koopa 'cliCheckSystem'
    koopa_alert_success 'System passed all checks.'
    return 0
}
