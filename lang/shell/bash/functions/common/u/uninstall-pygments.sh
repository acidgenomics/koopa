#!/usr/bin/env bash

koopa_uninstall_pygments() {
    koopa_uninstall_app \
        --name='pygments' \
        --unlink-in-bin='pygmentize' \
        "$@"
}
