#!/usr/bin/env bash

_koopa_uninstall_pipx() {
    _koopa_uninstall_app \
        --name='pipx' \
        "$@"
}
