#!/usr/bin/env bash

koopa_locate_xargs() {
    koopa_locate_app \
        --app-name='findutils' \
        --bin-name='gxargs' \
        --system-bin-name='xargs' \
        "$@"
}
