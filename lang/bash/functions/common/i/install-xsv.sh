#!/usr/bin/env bash

koopa_install_xsv() {
    koopa_install_app \
        --installer='conda-package' \
        --name='xsv' \
        "$@"
}
