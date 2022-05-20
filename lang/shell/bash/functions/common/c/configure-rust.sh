#!/usr/bin/env bash

koopa_configure_rust() {
    koopa_configure_app_packages \
        --name-fancy='Rust' \
        --name='rust' \
        "$@"
}
