#!/usr/bin/env bash

koopa_install_ranger_fm() {
    koopa_install_app \
        --installer='conda-package' \
        --name='ranger-fm' \
        "$@"
}
