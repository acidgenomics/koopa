#!/usr/bin/env bash

koopa_locate_nproc() {
    # """
    # Allowing passthrough of '--allow-missing' here.
    # """
    koopa_locate_app \
        --app-name='gnproc' \
        --opt-name='coreutils' \
        "$@"
}
