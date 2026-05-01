#!/usr/bin/env bash

_koopa_macos_locate_pmset() {
    _koopa_locate_app \
        '/usr/bin/pmset' \
        "$@"
}
