#!/usr/bin/env bash

koopa_locate_make() {
    koopa_locate_app \
        --app-name='make' \
        --bin-name='gmake' \
        --system-bin-name='make' \
        "$@"
}
