#!/usr/bin/env bash

koopa_locate_git() {
    koopa_locate_app \
        --app-name='git' \
        --bin-name='git' \
        "$@"
}
