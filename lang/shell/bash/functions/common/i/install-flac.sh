#!/usr/bin/env bash

koopa_install_flac() {
    koopa_install_app \
        --link-in-bin='bin/flac' \
        --name-fancy='FLAC' \
        --name='flac' \
        "$@"
}
