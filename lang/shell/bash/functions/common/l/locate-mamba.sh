#!/usr/bin/env bash

koopa_locate_mamba() {
    # """
    # Allowing passthrough of '--allow-missing' here.
    # """
    koopa_locate_app \
        --app-name='mamba' \
        --opt-name='conda' \
        "$@"
}
