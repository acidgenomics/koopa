#!/usr/bin/env bash

koopa_locate_md5sum() {
    local system_bin_name
    if koopa_is_macos
    then
        system_bin_name='md5'
    else
        system_bin_name='md5sum'
    fi
    koopa_locate_app \
        --app-name='coreutils' \
        --bin-name='gmd5sum' \
        --system-bin-name="$system_bin_name" \
        "$@"
}
