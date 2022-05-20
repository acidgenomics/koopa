#!/usr/bin/env bash

koopa_locate_rg() {
    # """
    # Allowing passthrough of '--allow-missing' here.
    # """
    koopa_locate_app \
        --app-name='rg' \
        --opt-name='ripgrep' \
        "$@"
}
