#!/usr/bin/env bash

koopa_install_tealdeer() {
    koopa_install_app \
        --installer='rust-package' \
        --link-in-bin='bin/tldr' \
        --name='tealdeer' \
        "$@"
}
