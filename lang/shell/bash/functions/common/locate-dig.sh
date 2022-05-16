#!/usr/bin/env bash

koopa_locate_dig() {
    # """
    # Allowing passthrough of '--allow-missing' here.
    # """
    koopa_locate_app \
        --app-name='dig' \
        --opt-name='bind' \
        "$@"
}
