#!/usr/bin/env zsh

_koopa_macos_is_dark_mode() {
    [[ "$( \
        /usr/bin/defaults read -g 'AppleInterfaceStyle' \
        2>/dev/null \
    )" == 'Dark' ]]
}
