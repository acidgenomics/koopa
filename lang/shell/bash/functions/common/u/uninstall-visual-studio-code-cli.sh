#!/usr/bin/env bash

koopa_uninstall_visual_studio_code_cli() {
    koopa_uninstall_app \
        --name='visual-studio-code-cli' \
        --system \
        "$@"
}
