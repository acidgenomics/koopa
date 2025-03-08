#!/usr/bin/env bash

# FIXME This needs to check system Python and R versions.
# FIXME This isn't checking man linkage correctly currently.
# FIXME Check for current clang headers for system R on macOS.
# FIXME Just move all checks into Python code, for simplicity.
# TODO Can we check for current Xcode CLT on macOS?

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
