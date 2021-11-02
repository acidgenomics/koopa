#!/usr/bin/env bash

koopa::arch_locate_pacman() { # {{{1
    # """
    # Locate Arch 'pacman'.
    # @note Updated 2021-11-02.
    # """
    koopa:::locate_app '/usr/sbin/pacman'
}

koopa::arch_locate_pacman_db_upgrade() { # {{{1
    # """
    # Locate Arch 'pacman'.
    # @note Updated 2021-11-02.
    # """
    koopa:::locate_app '/usr/sbin/pacman-db-upgrade'
}
