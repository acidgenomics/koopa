#!/usr/bin/env bash

_koopa_uninstall_system_homebrew() {
    _koopa_uninstall_app \
        --name='homebrew' \
        --system \
        "$@"
}
