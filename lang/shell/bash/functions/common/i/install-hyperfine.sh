#!/usr/bin/env bash

koopa_install_hyperfine() {
    koopa_install_app \
        --link-in-bin='hyperfine' \
        --name='hyperfine' \
        "$@"
}
