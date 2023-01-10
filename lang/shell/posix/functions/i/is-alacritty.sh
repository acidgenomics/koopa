#!/bin/sh

koopa_is_alacritty() {
    # """
    # Is Alacritty the current terminal client?
    # @note Updated 2022-05-06.
    # """
    [ -n "${ALACRITTY_SOCKET:-}" ]
}
