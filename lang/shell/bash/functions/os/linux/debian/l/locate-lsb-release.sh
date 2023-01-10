#!/usr/bin/env bash

koopa_debian_locate_lsb_release() {
    koopa_locate_app \
        '/usr/bin/lsb_release' \
        "$@"
}
