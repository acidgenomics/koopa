#!/usr/bin/env bash

_koopa_locate_ascp() {
    _koopa_locate_app \
        --app-name='aspera-connect' \
        --bin-name='ascp' \
        "$@"
}
