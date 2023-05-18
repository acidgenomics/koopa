#!/usr/bin/env bash

koopa_uninstall_jemalloc() {
    koopa_uninstall_app \
        --name='jemalloc' \
        "$@"
}
