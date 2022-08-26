#!/usr/bin/env bash

koopa_locate_md5sum() {
    koopa_locate_app \
        --app-name='coreutils' \
        --bin-name='gmd5sum' \
        "$@"
}
