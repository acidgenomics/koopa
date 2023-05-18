#!/usr/bin/env bash

koopa_locate_grep() {
    koopa_locate_app \
        --app-name='grep' \
        --bin-name='ggrep' \
        --system-bin-name='grep' \
        "$@"
}
