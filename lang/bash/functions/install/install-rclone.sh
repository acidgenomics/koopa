#!/usr/bin/env bash

_koopa_install_rclone() {
    _koopa_install_app \
        --installer='conda-package' \
        --name='rclone' \
        "$@"
}
