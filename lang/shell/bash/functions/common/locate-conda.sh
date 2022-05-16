#!/usr/bin/env bash

koopa_locate_conda() {
    # """
    # Allowing passthrough of '--allow-missing' here.
    # """
    koopa_locate_app \
        --app-name='conda' \
        --opt-name='conda' \
        "$@"
}
