#!/usr/bin/env bash

main() {
    koopa_install_app_subshell \
        --installer='python-package' \
        --name='yt-dlp' \
        -D --package-name='yt_dlp'
}
