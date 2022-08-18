#!/usr/bin/env bash

koopa_install_ranger_fm() {
    koopa_install_app \
        --link-in-bin='ranger' \
        --name='ranger-fm' \
        "$@"
}
