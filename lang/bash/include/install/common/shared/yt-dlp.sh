#!/usr/bin/env bash

# FIXME Look into tweaking certificate handling in build:
# https://github.com/yt-dlp/yt-dlp/issues/6892
# --compat-option no-certifi
# Or interactively can pass in --no-check-certificate

main() {
    koopa_install_python_package \
        --egg-name='yt_dlp'
    return 0
}
