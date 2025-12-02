#!/usr/bin/env bash

koopa_install_rclone() {
    koopa_install_app \
        --installer='conda-package' \
        --name='rclone' \
        "$@"
}
