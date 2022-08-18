#!/usr/bin/env bash

koopa_install_editorconfig() {
    koopa_install_app \
        --link-in-bin='editorconfig' \
        --name='editorconfig' \
        "$@"
}
