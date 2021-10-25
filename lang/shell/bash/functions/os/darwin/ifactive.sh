#!/usr/bin/env bash

# FIXME Need to locate pcregrep.
koopa::macos_ifactive() { # {{{1
    # """
    # Display active interfaces.
    # @note Updated 2021-10-25.
    # """
    koopa::assert_is_installed 'ifconfig' 'pcregrep'
    ifconfig | pcregrep -M -o '^[^\t:]+:([^\n]|\n\t)*status: active'
    return 0
}
