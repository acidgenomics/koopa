#!/usr/bin/env bash

_koopa_locate_grep() {
    _koopa_locate_app \
        --app-name='grep' \
        --bin-name='ggrep' \
        --system-bin-name='grep' \
        "$@"
}
