#!/usr/bin/env bash

koopa_uninstall_ffmpeg() {
    koopa_uninstall_app \
        --name-fancy='FFmpeg' \
        --name='ffmpeg' \
        --unlink-in-bin='ffmpeg' \
        "$@"
}
