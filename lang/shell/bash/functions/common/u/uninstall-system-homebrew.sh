#!/usr/bin/env bash

koopa_uninstall_system_homebrew() {
    koopa_uninstall_app \
        --name='homebrew' \
        --system \
        "$@"
}
