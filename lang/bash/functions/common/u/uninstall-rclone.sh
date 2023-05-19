#!/usr/bin/env bash

koopa_uninstall_rclone() {
    koopa_uninstall_app \
        --name='rclone' \
        "$@"
}
