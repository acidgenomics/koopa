#!/usr/bin/env bash

_koopa_install_yt_dlp() {
    _koopa_install_app \
        --installer='python-package' \
        --name='yt-dlp' \
        "$@"
}
