#!/usr/bin/env bash

koopa_install_ronn() {
    koopa_install_app \
        --installer='ruby-package' \
        --name='ronn' \
        "$@"
}
