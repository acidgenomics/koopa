#!/usr/bin/env bash

koopa_debian_locate_gdebi() {
    koopa_locate_app \
        '/usr/bin/gdebi' \
        "$@"
}
