#!/bin/sh

koopa_activate_difftastic() {
    # """
    # Activate difftastic.
    # @note Updated 2022-05-12.
    # """
    [ -x "$(koopa_bin_prefix)/difft" ] || return 0
    DFT_BACKGROUND="$(koopa_color_mode)"
    DFT_DISPLAY='side-by-side'
    export DFT_BACKGROUND DFT_DISPLAY
    return 0
}
