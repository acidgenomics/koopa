#!/usr/bin/env bash

_koopa_uninstall_jfrog_cli() {
    _koopa_uninstall_app \
        --name='jfrog-cli' \
        "$@"
}
