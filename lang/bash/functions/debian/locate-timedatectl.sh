#!/usr/bin/env bash

_koopa_debian_locate_timedatectl() {
    _koopa_locate_app \
        '/usr/bin/timedatectl' \
        "$@"
}
