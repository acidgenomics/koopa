#!/usr/bin/env bash

koopa_install_shellcheck() {
    koopa_install_app \
        --link-in-bin='bin/shellcheck' \
        --name-fancy='ShellCheck' \
        --name='shellcheck' \
        "$@"
}
