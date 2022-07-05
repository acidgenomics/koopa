#!/usr/bin/env bash

koopa_install_aspell() {
    koopa_install_app \
        --installer='gnu-app' \
        --link-in-bin='bin/aspell' \
        --name='aspell' \
        "$@"
}
