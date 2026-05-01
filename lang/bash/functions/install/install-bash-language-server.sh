#!/usr/bin/env bash

_koopa_install_bash_language_server() {
    _koopa_install_app \
        --installer='conda-package' \
        --name='bash-language-server' \
        "$@"
}
