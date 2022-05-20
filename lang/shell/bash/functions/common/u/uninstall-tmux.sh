#!/usr/bin/env bash

koopa_uninstall_tmux() {
    koopa_uninstall_app \
        --name='tmux' \
        --unlink-in-bin='tmux' \
        "$@"
}
