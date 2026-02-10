#!/usr/bin/env bash

koopa_uninstall_yamllint() {
    koopa_uninstall_app \
        --name='yamllint' \
        "$@"
}
