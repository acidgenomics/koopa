#!/usr/bin/env bash

koopa_uninstall_editorconfig() {
    koopa_uninstall_app \
        --name='editorconfig' \
        --unlink-in-bin='editorconfig' \
        "$@"
}
