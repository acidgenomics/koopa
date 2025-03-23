#!/usr/bin/env bash

koopa_macos_locate_kill_all() {
    koopa_locate_app \
        '/usr/bin/killAll' \
        "$@"
}
