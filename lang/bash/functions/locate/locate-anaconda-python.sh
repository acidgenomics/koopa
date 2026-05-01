#!/usr/bin/env bash

_koopa_locate_anaconda_python() {
    _koopa_locate_app \
        --app-name='anaconda' \
        --bin-name='python3' \
        --no-allow-koopa-bin \
        "$@"
}
