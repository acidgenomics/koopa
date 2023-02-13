#!/usr/bin/env bash

koopa_locate_python() {
    koopa_locate_app \
        --app-name='python3.11' \
        --bin-name='python3.11' \
        "$@"
}
