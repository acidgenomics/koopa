#!/usr/bin/env bash

koopa_uninstall_markdown() {
    koopa_uninstall_app \
        --name='markdown' \
        --unlink-in-bin='markdown' \
        "$@"
}
