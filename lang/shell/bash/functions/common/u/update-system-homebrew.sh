#!/usr/bin/env bash

koopa_update_system_homebrew() {
    koopa_update_app \
        --name='homebrew' \
        --prefix="$(koopa_homebrew_prefix)" \
        --system \
        "$@"
}
