#!/usr/bin/env bash

koopa_install_tealdeer() {
    koopa_install_app \
        --installer='rust-package' \
        --name='tealdeer' \
        "$@"
}
