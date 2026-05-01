#!/usr/bin/env bash

_koopa_locate_nimble() {
    _koopa_locate_app \
        --app-name='nim' \
        --bin-name='nimble' \
        "$@"
}
