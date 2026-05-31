#!/usr/bin/env bash

_koopa_activate_difftastic() {
    [[ -x "${KOOPA_PREFIX:?}/bin/difft" ]] || return 0
    DFT_BACKGROUND="${KOOPA_COLOR_MODE:?}"
    DFT_DISPLAY='side-by-side'
    export DFT_BACKGROUND DFT_DISPLAY
    return 0
}
