#!/usr/bin/env bash

_koopa_linux_uninstall_elfutils() {
    _koopa_uninstall_app \
        --name='elfutils' \
        --platform='linux' \
        "$@"
}
