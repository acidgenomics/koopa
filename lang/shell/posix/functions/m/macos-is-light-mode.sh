#!/bin/sh

_koopa_macos_is_light_mode() {
    # """
    # Is the current terminal running in light mode?
    # @note Updated 2021-05-05.
    # """
    ! _koopa_macos_is_dark_mode
}
