#!/usr/bin/env bash

_koopa_macos_locate_defaults() {
    _koopa_locate_app \
        '/usr/bin/defaults' \
        "$@"
}
