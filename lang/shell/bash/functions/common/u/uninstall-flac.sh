#!/usr/bin/env bash

koopa_uninstall_flac() {
    koopa_uninstall_app \
        --name='flac' \
        --unlink-in-bin='flac' \
        "$@"
}
