#!/usr/bin/env bash

koopa_install_cmake() {
    koopa_install_app \
        --link-in-bin='cmake' \
        --name='cmake' \
        "$@"
}
