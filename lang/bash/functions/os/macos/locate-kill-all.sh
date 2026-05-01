#!/usr/bin/env bash

_koopa_macos_locate_kill_all() {
    _koopa_locate_app \
        '/usr/bin/killAll' \
        "$@"
}
