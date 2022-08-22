#!/usr/bin/env bash

koopa_install_zstd() {
    koopa_install_app \
        --link-in-bin='pzstd' \
        --link-in-bin='unzstd' \
        --link-in-bin='zstd' \
        --link-in-bin='zstdcat' \
        --link-in-bin='zstdgrep' \
        --link-in-bin='zstdless' \
        --link-in-bin='zstdmt' \
        --name='zstd' \
        "$@"
}
