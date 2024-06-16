#!/usr/bin/env bash

# FIXME This isn't checking man linkage correctly currently.

koopa_check_system() {
    # """
    # Check system.
    # @note Updated 2024-05-28.
    # """
    koopa_assert_has_no_args "$#"
    koopa_python_script 'check-system.py'
    koopa_check_exports
    koopa_check_disk '/'
    koopa_alert_success 'System passed all checks.'
    return 0
}
