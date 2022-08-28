#!/usr/bin/env bash

koopa_uninstall_pipx() {
    koopa_uninstall_app \
        --name='pipx' \
        "$@"
}
