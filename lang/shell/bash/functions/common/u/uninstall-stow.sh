#!/usr/bin/env bash

koopa_uninstall_stow() {
    koopa_uninstall_app \
        --name='stow' \
        --unlink-in-bin='stow' \
        "$@"
}
