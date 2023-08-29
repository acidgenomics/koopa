#!/usr/bin/env bash

koopa_install_subread() {
    koopa_install_app \
        --installer='conda-package' \
        --name='subread' \
        "$@"
}
