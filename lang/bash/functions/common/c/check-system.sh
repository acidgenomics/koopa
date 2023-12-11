#!/usr/bin/env bash

koopa_check_system() {
    # """
    # Check system.
    # @note Updated 2023-12-11.
    # """
    koopa_assert_has_no_args "$#"
    koopa_alert 'Checking system.'
    # FIXME Need to add support for this.
    koopa_python_script 'check-system.py'
    koopa_check_exports
    koopa_check_disk '/'
    koopa_alert_success 'System passed all checks.'
    return 0
}
