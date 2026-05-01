#!/usr/bin/env bash

_koopa_locate_ffmpeg() {
    _koopa_locate_app \
        --app-name='ffmpeg' \
        --bin-name='ffmpeg' \
        "$@"
}
