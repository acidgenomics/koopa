#!/usr/bin/env bash

koopa_locate_anaconda_conda() {
    koopa_locate_app \
        --app-name='anaconda' \
        --bin-name='conda' \
        --no-allow-koopa-bin \
        "$@"
}
