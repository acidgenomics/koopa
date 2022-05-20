#!/usr/bin/env bash

koopa_uninstall_hyperfine() {
    koopa_uninstall_app \
        --name='hyperfine' \
        --unlink-in-bin='hyperfine' \
        "$@"
}
