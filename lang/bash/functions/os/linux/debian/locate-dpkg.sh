#!/usr/bin/env bash

_koopa_debian_locate_dpkg() {
    _koopa_locate_app \
        '/usr/bin/dpkg' \
        "$@"
}
