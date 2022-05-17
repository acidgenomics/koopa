#!/usr/bin/env bash

koopa_install_exa() {
    koopa_install_app \
        --link-in-bin='bin/exa' \
        --name='exa' \
        --installer='rust-package' \
        "$@"
}
