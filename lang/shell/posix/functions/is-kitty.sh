#!/bin/sh

koopa_is_kitty() {
    # """
    # Is Kitty the active terminal?
    # @note Updated 2022-05-06.
    # """
    [ -n "${KITTY_PID:-}" ]
}
