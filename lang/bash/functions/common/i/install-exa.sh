#!/usr/bin/env bash

koopa_install_exa() {
    koopa_install_app \
        --installer='rust-package' \
        --name='exa' \
        "$@"
}
