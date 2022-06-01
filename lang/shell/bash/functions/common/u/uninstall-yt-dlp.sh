#!/usr/bin/env bash

koopa_uninstall_yt_dlp() {
    koopa_uninstall_app \
        --name='yt-dlp' \
        --unlink-in-bin='yt-dlp' \
        "$@"
}
