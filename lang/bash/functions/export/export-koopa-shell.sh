#!/usr/bin/env bash

_koopa_export_koopa_shell() {
    KOOPA_SHELL="${BASH}"
    [[ -z "${SHELL:-}" ]] && SHELL="$KOOPA_SHELL"
    export KOOPA_SHELL SHELL
    return 0
}
