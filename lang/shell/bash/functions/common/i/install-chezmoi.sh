#!/usr/bin/env bash

koopa_install_chezmoi() {
    koopa_install_app \
        --link-in-bin='chezmoi' \
        --name='chezmoi' \
        "$@"
}
