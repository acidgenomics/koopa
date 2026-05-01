#!/usr/bin/env bash

_koopa_arch_locate_pacman_db_upgrade() {
    _koopa_locate_app \
        '/usr/sbin/pacman-db-upgrade' \
        "$@"
}
