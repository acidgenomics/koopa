#!/usr/bin/env bash

_koopa_locate_find() {
    _koopa_locate_app \
        --app-name='findutils' \
        --bin-name='gfind' \
        --system-bin-name='find' \
        "$@"
}
