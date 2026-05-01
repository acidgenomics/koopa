#!/usr/bin/env bash

_koopa_locate_anaconda_conda() {
    _koopa_locate_app \
        --app-name='anaconda' \
        --bin-name='conda' \
        --no-allow-koopa-bin \
        "$@"
}
