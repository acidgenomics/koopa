#!/usr/bin/env bash

# FIXME This isn't checking man linkage correctly currently.
# FIXME Just move all checks into Python code, for simplicity.

koopa_check_system() {
    # """
    # Check system.
    # @note Updated 2024-09-23.
    # """
    koopa_assert_has_no_args "$#"
    koopa_check_build_system
    koopa_python_script 'check-system.py'
    koopa_check_disk '/'
    # > koopa_check_exports
    koopa_alert_success 'System passed all checks.'
    return 0
}
