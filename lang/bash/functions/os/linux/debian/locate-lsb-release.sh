#!/usr/bin/env bash

_koopa_debian_locate_lsb_release() {
    _koopa_locate_app \
        '/usr/bin/lsb_release' \
        "$@"
}
