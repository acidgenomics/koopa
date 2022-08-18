#!/usr/bin/env bash

koopa_install_tokei() {
    koopa_install_app \
        --link-in-bin='tokei' \
        --name='tokei' \
        "$@"
}
