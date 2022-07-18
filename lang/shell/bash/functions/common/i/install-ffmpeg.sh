#!/usr/bin/env bash

koopa_install_ffmpeg() {
    koopa_install_app \
        --link-in-bin='ffmpeg' \
        --link-in-bin='ffprobe' \
        --name='ffmpeg' \
        "$@"
}
