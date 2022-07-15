#!/bin/sh
# shellcheck disable=all

koopa_arch_install_system_base() {
    koopa_install_app \
        --name-fancy='Arch base system' \
        --name='base' \
        --platform='arch' \
        --system \
        "$@"
}

koopa_arch_locate_pacman_db_upgrade() {
    koopa_locate_app '/usr/sbin/pacman-db-upgrade'
}

koopa_arch_locate_pacman() {
    koopa_locate_app '/usr/sbin/pacman'
}
