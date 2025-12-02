#!/usr/bin/env bash

koopa_install_csvtk() {
    koopa_install_app \
        --installer='conda-package' \
        --name='csvtk' \
        "$@"
}
