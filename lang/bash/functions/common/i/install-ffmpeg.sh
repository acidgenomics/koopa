#!/usr/bin/env bash

koopa_install_ffmpeg() {
    koopa_install_app \
        --installer='conda-package' \
        --name='ffmpeg' \
        "$@"
}
