#!/usr/bin/env bash

koopa_install_umis() {
    koopa_install_app \
        --installer='conda-package' \
        --name='umis' \
        "$@"
}
