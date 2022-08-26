#!/usr/bin/env bash

## FIXME This is Linux specific.

koopa_locate_ldd() {
    koopa_locate_app \
        '/usr/bin/ldd' \
        "$@"
}
