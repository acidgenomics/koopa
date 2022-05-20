#!/bin/sh
# shellcheck disable=all
koopa_arch_install_base_system() {
    koopa_install_app \
        --name-fancy='Arch base system' \
        --name='base-system' \
        --platform='arch' \
        --system \
        "$@"
}
koopa_arch_locate_pacman() {
    koopa_locate_app '/usr/sbin/pacman'
}
koopa_arch_locate_pacman_db_upgrade() {
    koopa_locate_app '/usr/sbin/pacman-db-upgrade'
}
