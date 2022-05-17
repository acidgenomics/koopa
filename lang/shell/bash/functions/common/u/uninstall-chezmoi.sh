#!/usr/bin/env bash

koopa_uninstall_chezmoi() {
    koopa_uninstall_app \
        --name='chezmoi' \
        --unlink-in-bin='chezmoi' \
        "$@"
}
