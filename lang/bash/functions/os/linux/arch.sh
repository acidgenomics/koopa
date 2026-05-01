#!/usr/bin/env bash
# shellcheck disable=all

_koopa_arch_locate_pacman_db_upgrade() {
    _koopa_locate_app \
        '/usr/sbin/pacman-db-upgrade' \
        "$@"
}

_koopa_arch_locate_pacman() {
    _koopa_locate_app \
        '/usr/sbin/pacman' \
        "$@"
}
