#!/usr/bin/env bash

koopa_install_pyenv() {
    koopa_install_app \
        --link-in-bin='pyenv' \
        --name='pyenv' \
        "$@"
}
