#!/usr/bin/env bash

koopa_uninstall_flac() {
    koopa_uninstall_app \
        --name-fancy='FLAC' \
        --name='flac' \
        --unlink-in-bin='flac' \
        "$@"
}
