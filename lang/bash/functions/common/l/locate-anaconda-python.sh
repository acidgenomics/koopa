#!/usr/bin/env bash

koopa_locate_anaconda_python() {
    koopa_locate_app \
        --app-name='anaconda' \
        --bin-name='python3' \
        --no-allow-koopa-bin \
        "$@"
}
