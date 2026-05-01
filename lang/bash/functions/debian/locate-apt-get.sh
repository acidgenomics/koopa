#!/usr/bin/env bash

_koopa_debian_locate_apt_get() {
    _koopa_locate_app \
        '/usr/bin/apt-get' \
        "$@"
}
