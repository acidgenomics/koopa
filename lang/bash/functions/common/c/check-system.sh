#!/usr/bin/env bash

# FIXME Rework this in Python.

koopa_check_system() {
    # """
    # Check system.
    # @note Updated 2023-12-05.
    # """
    koopa_assert_has_no_args "$#"
    koopa_stop 'FIXME REWORKING THIS IN PYTHON.'
    koopa_alert_start 'Checking system.'
    koopa_check_exports
    koopa_check_disk '/'
    koopa_alert_success 'System passed all checks.'
    return 0
}
