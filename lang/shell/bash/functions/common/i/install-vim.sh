#!/usr/bin/env bash

koopa_install_vim() {
    koopa_install_app \
        --link-in-bin='vim' \
        --link-in-bin='vimdiff' \
        --name='vim' \
        "$@"
}
