#!/usr/bin/env bash

koopa_locate_python3() {
    koopa_locate_app \
        --app-name='python3.12' \
        --bin-name='python3' \
        "$@"
}
