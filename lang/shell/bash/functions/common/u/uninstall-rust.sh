#!/usr/bin/env bash

koopa_uninstall_rust() {
    koopa_uninstall_app \
        --name-fancy='Rust' \
        --name='rust' \
        "$@"
}
