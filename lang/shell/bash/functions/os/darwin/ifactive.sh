#!/usr/bin/env bash

koopa::macos_ifactive() { # {{{1
    # """
    # Display active interfaces.
    # @note Updated 2020-07-16.
    # """
    koopa::assert_is_installed 'ifconfig' 'pcregrep'
    ifconfig | pcregrep -M -o '^[^\t:]+:([^\n]|\n\t)*status: active'
    return 0
}

