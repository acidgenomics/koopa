#!/usr/bin/env bash

koopa_install_yarn() {
    koopa_install_app \
        --link-in-bin='yarn' \
        --name='yarn' \
        "$@"
}
