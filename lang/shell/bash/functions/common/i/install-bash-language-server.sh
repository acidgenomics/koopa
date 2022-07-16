#!/usr/bin/env bash

koopa_install_bash_language_server() {
    koopa_install_app \
        --installer='node-package' \
        --link-in-bin='bash-language-server' \
        --name='bash-language-server' \
        "$@"
}
