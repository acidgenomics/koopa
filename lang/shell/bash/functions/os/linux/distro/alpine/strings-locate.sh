#!/usr/bin/env bash

koopa::alpine_locate_apk() { # {{{1
    # """
    # Locate Alpine 'apk'.
    # @note Updated 2021-11-02.
    # """
    koopa::locate_app '/sbin/apk'
}

koopa::alpine_locate_localedef() { # {{{1
    # """
    # Locate Alpine 'localedef'.
    # @note Updated 2021-11-02.
    # """
    koopa::locate_app '/usr/glibc-compat/bin/localedef'
}
