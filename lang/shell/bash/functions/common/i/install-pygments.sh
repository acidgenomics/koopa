#!/usr/bin/env bash

koopa_install_pygments() {
    koopa_install_app \
        --link-in-bin='pygmentize' \
        --name='pygments' \
        "$@"
}
