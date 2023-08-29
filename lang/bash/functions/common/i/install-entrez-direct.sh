#!/usr/bin/env bash

koopa_install_entrez_direct() {
    koopa_install_app \
        --installer='conda-package' \
        --name='entrez-direct' \
        "$@"
}
