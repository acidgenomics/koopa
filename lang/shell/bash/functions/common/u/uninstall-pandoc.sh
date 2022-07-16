#!/usr/bin/env bash

koopa_uninstall_pandoc() {
    koopa_uninstall_app \
        --name='pandoc' \
        --unlink-in-bin='pandoc' \
        "$@"
}
