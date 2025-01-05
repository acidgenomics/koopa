#!/usr/bin/env bash

koopa_install_tokei() {
    koopa_install_app \
        --installer='conda-package' \
        --name='tokei' \
        "$@"
}
