#!/usr/bin/env bash

_koopa_uninstall_k9s() {
    _koopa_uninstall_app \
        --name='k9s' \
        "$@"
}
