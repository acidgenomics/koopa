#!/usr/bin/env bash

koopa_uninstall_wget() {
    koopa_uninstall_app \
        --name='wget' \
        --unlink-in-bin='wget' \
        "$@"
}
