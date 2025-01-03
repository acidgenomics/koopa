#!/usr/bin/env bash

koopa_install_starship() {
    koopa_install_app \
        --installer='conda-package' \
        --name='starship' \
        "$@"
}
