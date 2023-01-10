#!/bin/sh

koopa_macos_is_light_mode() {
    # """
    # Is the current terminal running in light mode?
    # @note Updated 2021-05-05.
    # """
    ! koopa_macos_is_dark_mode
}
