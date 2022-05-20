#!/usr/bin/env bash

koopa_update_homebrew() {
    koopa_update_app \
        --name-fancy='Homebrew' \
        --name='homebrew' \
        --system \
        "$@"
}
