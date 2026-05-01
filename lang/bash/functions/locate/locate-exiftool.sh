#!/usr/bin/env bash

_koopa_locate_exiftool() {
    _koopa_locate_app \
        --app-name='exiftool' \
        --bin-name='exiftool' \
        "$@"
}
