#!/usr/bin/env bash

koopa_update_system_homebrew() {
    koopa_update_app \
        --name-fancy='Homebrew' \
        --name='homebrew' \
        --system \
        "$@"
}
