#!/usr/bin/env zsh

_koopa_export_koopa_shell() {
    KOOPA_SHELL="${ZSH_ARGZERO}"
    [[ -z "${SHELL:-}" ]] && SHELL="$KOOPA_SHELL"
    export KOOPA_SHELL SHELL
    return 0
}
