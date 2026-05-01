#!/usr/bin/env bash

_koopa_uninstall_jemalloc() {
    _koopa_uninstall_app \
        --name='jemalloc' \
        "$@"
}
