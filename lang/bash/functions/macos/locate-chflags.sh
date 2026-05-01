#!/usr/bin/env bash

_koopa_macos_locate_chflags() {
    _koopa_locate_app \
        '/usr/bin/chflags' \
        "$@"
}
