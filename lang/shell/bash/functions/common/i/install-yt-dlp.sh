#!/usr/bin/env bash

koopa_install_yt_dlp() {
    koopa_install_app \
        --installer='python-venv' \
        --link-in-bin='bin/yt-dlp' \
        --name='yt-dlp' \
        "$@"
}
