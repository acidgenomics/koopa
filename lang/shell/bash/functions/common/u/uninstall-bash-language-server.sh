#!/usr/bin/env bash

koopa_uninstall_bash_language_server() {
    koopa_uninstall_app \
        --name='bash-language-server' \
        --unlink-in-bin='bash-language-server' \
        "$@"
}
