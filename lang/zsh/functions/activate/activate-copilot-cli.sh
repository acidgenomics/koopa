#!/usr/bin/env zsh

_koopa_activate_copilot_cli() {
    [[ -x "${KOOPA_PREFIX:?}/bin/copilot" ]] || return 0
    export COPILOT_AUTO_UPDATE=false
    return 0
}
