#!/usr/bin/env bash

koopa::opensuse_locate_zypper() { # {{{1
    # """
    # Locate OpenSUSE 'zypper'.
    # @note Updated 2021-11-16.
    # """
    koopa::locate_app '/usr/bin/zypper'
}
