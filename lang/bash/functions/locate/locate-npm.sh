#!/usr/bin/env bash

_koopa_locate_npm() {
    _koopa_locate_app \
        --app-name='node' \
        --bin-name='npm' \
        "$@"
}
