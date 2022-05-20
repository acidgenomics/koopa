#!/usr/bin/env bash

koopa_locate_fd() {
    # """
    # Allowing passthrough of '--allow-missing' here.
    # """
    koopa_locate_app \
        --app-name='fd' \
        --opt-name='fd-find' \
        "$@"
}
