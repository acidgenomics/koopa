#!/usr/bin/env bash

koopa_install_tmux() {
    koopa_install_app \
        --link-in-bin='tmux' \
        --name='tmux' \
        "$@"
}
