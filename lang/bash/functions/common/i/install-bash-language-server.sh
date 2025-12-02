#!/usr/bin/env bash

koopa_install_bash_language_server() {
    koopa_install_app \
        --installer='conda-package' \
        --name='bash-language-server' \
        "$@"
}
