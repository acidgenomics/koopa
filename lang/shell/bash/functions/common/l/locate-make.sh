#!/usr/bin/env bash

koopa_locate_make() {
    # """
    # Allowing passthrough of '--allow-missing' here.
    # """
    koopa_locate_app \
        --app-name='gmake' \
        --opt-name='make' \
        "$@"
}
