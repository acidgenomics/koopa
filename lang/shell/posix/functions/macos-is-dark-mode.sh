#!/bin/sh

koopa_macos_is_dark_mode() {
    # """
    # Is the current macOS terminal running in dark mode?
    # @note Updated 2021-05-05.
    # """
    local x
    x=$(defaults read -g 'AppleInterfaceStyle' 2>/dev/null)
    [ "$x" = 'Dark' ]
}
