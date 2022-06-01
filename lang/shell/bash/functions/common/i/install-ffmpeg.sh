#!/usr/bin/env bash

koopa_install_ffmpeg() {
    koopa_install_app \
        --link-in-bin='bin/ffmpeg' \
        --name-fancy='FFmpeg' \
        --name='ffmpeg' \
        "$@"
}
