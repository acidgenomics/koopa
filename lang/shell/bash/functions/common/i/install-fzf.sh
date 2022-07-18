#!/usr/bin/env bash

koopa_install_fzf() {
    koopa_install_app \
        --link-in-bin='fzf' \
        --name='fzf' \
        "$@"
}
