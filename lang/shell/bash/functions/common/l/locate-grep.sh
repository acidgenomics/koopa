#!/usr/bin/env bash

koopa_locate_grep() {
    koopa_locate_app \
        --allow-in-path \
        --app-name='grep' \
        --opt-name='grep' \
        "$@"
}
