#!/usr/bin/env bash

_koopa_macos_locate_automount() {
    _koopa_locate_app \
        '/usr/sbin/automount' \
        "$@"
}
