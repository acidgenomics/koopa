#!/usr/bin/env bash

koopa_locate_conda() {
    koopa_locate_app \
        --app-name='conda' \
        --bin-name='conda' \
        "$@"
}
