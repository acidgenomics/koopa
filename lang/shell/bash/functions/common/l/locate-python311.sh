#!/usr/bin/env bash

koopa_locate_python311() {
    koopa_locate_app \
        --app-name='python3.11' \
        --bin-name='python3.11' \
        "$@"
}
