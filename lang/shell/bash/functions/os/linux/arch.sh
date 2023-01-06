#!/usr/bin/env bash
# shellcheck disable=all

koopa_arch_locate_pacman_db_upgrade() {
    koopa_locate_app \
        '/usr/sbin/pacman-db-upgrade' \
        "$@"
}

koopa_arch_locate_pacman() {
    koopa_locate_app \
        '/usr/sbin/pacman' \
        "$@"
}
