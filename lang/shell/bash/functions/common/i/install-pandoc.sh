#!/usr/bin/env bash

koopa_install_pandoc() {
    koopa_install_app \
        --link-in-bin='bin/pandoc' \
        --name-fancy='Pandoc' \
        --name='pandoc' \
        "$@"
}
