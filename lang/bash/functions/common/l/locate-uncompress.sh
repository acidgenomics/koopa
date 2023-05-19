#!/usr/bin/env bash

koopa_locate_uncompress() {
    koopa_locate_app \
        --app-name='gzip' \
        --bin-name='uncompress' \
        "$@"
}
