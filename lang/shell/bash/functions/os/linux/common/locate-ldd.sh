#!/usr/bin/env bash

koopa_linux_locate_ldd() {
    koopa_locate_app \
        '/usr/bin/ldd' \
        "$@"
}
