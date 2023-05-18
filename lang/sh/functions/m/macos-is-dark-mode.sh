#!/bin/sh

_koopa_macos_is_dark_mode() {
    # """
    # Is the current macOS terminal running in dark mode?
    # @note Updated 2023-03-11.
    # """
    [ \
        "$( \
            /usr/bin/defaults read -g 'AppleInterfaceStyle' \
            2>/dev/null \
        )" = 'Dark' \
    ]
}
