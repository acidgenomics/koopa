#!/usr/bin/env bash

_koopa_locate_node() {
    _koopa_locate_app \
        --app-name='node' \
        --bin-name='node' \
        "$@"
}
