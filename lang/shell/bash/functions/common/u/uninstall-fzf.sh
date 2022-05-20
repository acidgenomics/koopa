#!/usr/bin/env bash

koopa_uninstall_fzf() {
    koopa_uninstall_app \
        --name-fancy='FZF' \
        --name='fzf' \
        --unlink-in-bin='fzf' \
        "$@"
}
