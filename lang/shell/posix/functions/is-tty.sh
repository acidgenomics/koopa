#!/bin/sh

koopa_is_tty() {
    # """
    # Is current shell a teletypewriter?
    # @note Updated 2020-07-03.
    # """
    koopa_is_installed 'tty' || return 1
    tty >/dev/null 2>&1 || false
}
