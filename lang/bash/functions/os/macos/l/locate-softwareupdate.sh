#!/usr/bin/env bash

koopa_macos_locate_softwareupdate() {
    koopa_locate_app \
        '/usr/sbin/softwareupdate' \
        "$@"
}
