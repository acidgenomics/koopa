#!/usr/bin/env bash

koopa_locate_rustc() {
    koopa_locate_app \
        --app-name='rust' \
        --bin-name='rustc' \
        "$@"
}
