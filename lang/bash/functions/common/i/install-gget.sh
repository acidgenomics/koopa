#!/usr/bin/env bash

koopa_install_gget() {
    koopa_install_app \
        --installer='conda-package' \
        --name='gget' \
        "$@"
}
