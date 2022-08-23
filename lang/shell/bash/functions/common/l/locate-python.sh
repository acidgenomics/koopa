#!/usr/bin/env bash

koopa_locate_python() {
    koopa_locate_app \
        --allow-in-path \
        --app-name='python3' \
        --opt-name='python' \
        "$@"
}
