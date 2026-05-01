#!/usr/bin/env bash

_koopa_linux_uninstall_lmod() {
    _koopa_uninstall_app \
        --name='lmod' \
        --platform='linux' \
        "$@"
}
