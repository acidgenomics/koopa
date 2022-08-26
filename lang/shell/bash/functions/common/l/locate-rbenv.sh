#!/usr/bin/env bash

koopa_locate_rbenv() {
    koopa_locate_app \
        --app-name='rbenv' \
        --bin-name='rbenv' \
        "$@"
}
