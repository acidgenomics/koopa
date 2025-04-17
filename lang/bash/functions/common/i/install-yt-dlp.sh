#!/usr/bin/env bash

koopa_install_yt_dlp() {
    koopa_install_app \
        --installer='python-package' \
        --name='yt-dlp' \
        "$@"
}
