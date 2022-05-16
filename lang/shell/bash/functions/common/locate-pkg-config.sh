#!/usr/bin/env bash

koopa_locate_pkg_config() {
    # """
    # Allowing passthrough of '--allow-missing' here.
    # """
    koopa_locate_app \
        --app-name='pkg-config' \
        --opt-name='pkg-config' \
        "$@"
}
