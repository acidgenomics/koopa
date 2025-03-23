#!/usr/bin/env bash

koopa_locate_mamba() {
    koopa_locate_app \
        --app-name='conda' \
        --bin-name='mamba' \
        "$@"
}
