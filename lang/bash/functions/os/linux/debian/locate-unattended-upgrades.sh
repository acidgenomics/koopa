#!/usr/bin/env bash

_koopa_debian_locate_unattended_upgrades() {
    _koopa_locate_app \
        '/usr/bin/unattended-upgrades' \
        "$@"
}
