#!/usr/bin/env bash

koopa_uninstall_shellcheck() {
    koopa_uninstall_app \
        --name-fancy='ShellCheck' \
        --name='shellcheck' \
        --unlink-in-bin='shellcheck' \
        "$@"
}
