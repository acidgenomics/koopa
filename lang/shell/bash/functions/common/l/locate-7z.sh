#!/usr/bin/env bash

koopa_locate_7z() {
    koopa_locate_app \
        --app-name='p7zip' \
        --bin-name='7z'
        "$@" \
}
