#!/usr/bin/env bash

_koopa_install_ffmpeg() {
    _koopa_install_app \
        --installer='conda-package' \
        --name='ffmpeg' \
        "$@"
}
