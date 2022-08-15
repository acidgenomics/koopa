#!/usr/bin/env bash

koopa_install_exa() {
    koopa_install_app \
        --link-in-bin='exa' \
        --name='exa' \
        "$@"
}
