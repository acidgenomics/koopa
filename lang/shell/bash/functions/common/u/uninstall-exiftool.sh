#!/usr/bin/env bash

koopa_uninstall_exiftool() {
    koopa_uninstall_app \
        --name='exiftool' \
        --unlink-in-bin='exiftool' \
        "$@"
}
