#!/usr/bin/env bash

koopa_macos_locate_chflags() {
    koopa_locate_app \
        '/usr/bin/chflags' \
        "$@"
}
