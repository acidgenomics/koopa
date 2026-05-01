#!/usr/bin/env bash

_koopa_macos_locate_softwareupdate() {
    _koopa_locate_app \
        '/usr/sbin/softwareupdate' \
        "$@"
}
