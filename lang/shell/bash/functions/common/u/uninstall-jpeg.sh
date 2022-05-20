#!/usr/bin/env bash

# NOTE Consider renaming this to 'libjpeg'.

koopa_uninstall_jpeg() {
    koopa_uninstall_app \
        --name='jpeg' \
        "$@"
}
