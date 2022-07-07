#!/usr/bin/env bash

koopa_install_ffmpeg() {
    koopa_install_app \
        --link-in-bin='bin/ffmpeg' \
        --link-in-bin='bin/ffprobe' \
        --name-fancy='FFmpeg' \
        --name='ffmpeg' \
        "$@"
}
