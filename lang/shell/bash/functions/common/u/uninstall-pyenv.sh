#!/usr/bin/env bash

koopa_uninstall_pyenv() {
    koopa_uninstall_app \
        --name='pyenv' \
        --unlink-in-bin='pyenv' \
        "$@"
}
