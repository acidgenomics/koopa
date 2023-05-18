#!/usr/bin/env bash

koopa_debian_locate_apt() {
    koopa_locate_app \
        '/usr/bin/apt' \
        "$@"
}
