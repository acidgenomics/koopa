#!/usr/bin/env bash

_koopa_export_koopa_shell() {
    if [[ -z "${KOOPA_SHELL:-}" ]]
    then
        KOOPA_SHELL="$(_koopa_locate_shell)"
    fi
    [[ -z "${SHELL:-}" ]] && SHELL="$KOOPA_SHELL"
    export KOOPA_SHELL SHELL
    return 0
}
