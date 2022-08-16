#!/usr/bin/env bash

koopa_install_yt_dlp() {
    koopa_install_app \
        --link-in-bin='yt-dlp' \
        --name='yt-dlp' \
        "$@"
}
