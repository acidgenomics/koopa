#!/usr/bin/env bash

koopa_uninstall_vim() {
    koopa_uninstall_app \
        --name='vim' \
        --unlink-in-bin='vim' \
        --unlink-in-bin='vimdiff' \
        "$@"
}
