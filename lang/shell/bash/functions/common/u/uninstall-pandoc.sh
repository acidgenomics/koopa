#!/usr/bin/env bash

koopa_uninstall_pandoc() {
    koopa_uninstall_app \
        --name-fancy='Pandoc' \
        --name='pandoc' \
        --unlink-in-bin='pandoc' \
        "$@"
}
