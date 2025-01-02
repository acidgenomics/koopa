#!/usr/bin/env bash

koopa_install_bash_completion() {
    koopa_install_app \
        --name='bash-completion' \
        "$@"
    return 0
}
