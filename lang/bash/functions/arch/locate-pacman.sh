#!/usr/bin/env bash

_koopa_arch_locate_pacman() {
    _koopa_locate_app \
        '/usr/sbin/pacman' \
        "$@"
}
