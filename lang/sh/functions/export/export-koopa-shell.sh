#!/bin/sh

_koopa_export_koopa_shell() {
    # """
    # Export 'KOOPA_SHELL' and 'SHELL' variables.
    # @note Updated 2023-05-12.
    # """
    unset -v KOOPA_SHELL
    KOOPA_SHELL="$(_koopa_locate_shell)"
    [ -z "${SHELL:-}" ] && SHELL="$KOOPA_SHELL"
    export KOOPA_SHELL SHELL
    return 0
}
