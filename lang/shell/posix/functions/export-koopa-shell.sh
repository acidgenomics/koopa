#!/bin/sh

koopa_export_koopa_shell() {
    # """
    # Export 'KOOPA_SHELL' variable.
    # @note Updated 2022-02-02.
    # """
    unset -v KOOPA_SHELL
    KOOPA_SHELL="$(koopa_locate_shell)"
    export KOOPA_SHELL
    return 0
}
