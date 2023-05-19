#!/usr/bin/env bash

koopa_debian_locate_apt_get() {
    koopa_locate_app \
        '/usr/bin/apt-get' \
        "$@"
}
