#!/usr/bin/env bash

koopa_uninstall_zstd() {
    koopa_uninstall_app \
        --name='zstd' \
        --unlink-in-bin='pzstd' \
        --unlink-in-bin='unzstd' \
        --unlink-in-bin='zstd' \
        --unlink-in-bin='zstdcat' \
        --unlink-in-bin='zstdgrep' \
        --unlink-in-bin='zstdless' \
        --unlink-in-bin='zstdmt' \
        "$@"
}
