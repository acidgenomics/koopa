#!/usr/bin/env bash

koopa_uninstall_ffmpeg() {
    koopa_uninstall_app \
        --name='ffmpeg' \
        --unlink-in-bin='ffmpeg' \
        --unlink-in-bin='ffprobe' \
        "$@"
}
