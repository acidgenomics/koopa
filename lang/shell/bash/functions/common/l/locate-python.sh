#!/usr/bin/env bash

koopa_locate_python() {
    koopa_locate_app \
        --app-name='python' \
        --bin-name='python3' \
        "$@"
}
