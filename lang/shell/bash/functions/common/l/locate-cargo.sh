#!/usr/bin/env bash

koopa_locate_cargo() {
    koopa_locate_app \
        --app-name='rust' \
        --bin-name='cargo' \
        "$@"
}
