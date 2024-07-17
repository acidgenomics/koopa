#!/usr/bin/env bash

koopa_uninstall_jfrog_cli() {
    koopa_uninstall_app \
        --name='jfrog-cli' \
        "$@"
}
