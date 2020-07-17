#!/usr/bin/env bash

koopa::macos_flush_dns() { # {{{1
    # """
    # Flush DNS cache.
    # @note Updated 2020-07-17.
    # """
    koopa::assert_has_no_args "$#"
    koopa::h1 'Flushing DNS.'
    sudo dscacheutil -flushcache
    sudo killall -HUP mDNSResponder
    koopa::success 'DNS flush was successful.'
    return 0
}
