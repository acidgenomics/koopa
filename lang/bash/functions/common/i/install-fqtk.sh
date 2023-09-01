#!/usr/bin/env bash

koopa_install_fqtk() {
    koopa_install_app \
        --installer='conda-package' \
        --name='fqtk' \
        "$@"
}
