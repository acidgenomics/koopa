#!/usr/bin/env bash

koopa_install_app_internal() {
    koopa_install_app \
        --no-link-in-opt \
        --no-prefix-check \
        --quiet \
        "$@"
}
