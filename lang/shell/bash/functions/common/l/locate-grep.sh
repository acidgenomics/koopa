#!/usr/bin/env bash

koopa_locate_grep() {
    koopa_locate_app \
        --app-name='ggrep' \
        --opt-name='grep' \
        "$@"
}
