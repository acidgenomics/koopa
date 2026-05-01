#!/usr/bin/env bash

_koopa_debian_locate_gdebi() {
    _koopa_locate_app \
        '/usr/bin/gdebi' \
        "$@"
}
