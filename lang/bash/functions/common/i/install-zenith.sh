#!/usr/bin/env bash

koopa_install_zenith() {
    koopa_install_app \
        --installer='conda-package' \
        --name='zenith' \
        "$@"
}
