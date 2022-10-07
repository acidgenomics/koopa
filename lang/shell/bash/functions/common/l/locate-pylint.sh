#!/usr/bin/env bash

koopa_locate_pylint() {
    koopa_locate_app \
        --app-name='pylint' \
        --bin-name='pylint' \
        "$@"
}
