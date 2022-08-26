#!/usr/bin/env bash

koopa_locate_find() {
    koopa_locate_app \
        --app-name='findutils' \
        --bin-name='gfind' \
        "$@"
}
