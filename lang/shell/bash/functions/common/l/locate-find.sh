#!/usr/bin/env bash

koopa_locate_find() {
    # """
    # Allowing passthrough of '--allow-missing'.
    # """
    koopa_locate_app \
        --app-name='gfind' \
        --opt-name='findutils' \
        "$@"
}
