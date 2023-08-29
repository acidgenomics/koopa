#!/usr/bin/env bash

koopa_install_nanopolish() {
    koopa_install_app \
        --installer='conda-package' \
        --name='nanopolish' \
        "$@"
}
