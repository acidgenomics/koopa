#!/usr/bin/env bash

koopa_locate_mv() {
    # """
    # @note macOS gmv currently has issues on NFS shares.
    # """
    if koopa_is_macos
    then
        koopa_locate_app '/bin/mv'
    else
        koopa_locate_app \
            --allow-in-path \
            --app-name='mv' \
            --opt-name='coreutils'
    fi
}
