#!/usr/bin/env bash

koopa_uninstall_shellcheck() {
    koopa_uninstall_app \
        --name='shellcheck' \
        "$@"
}
