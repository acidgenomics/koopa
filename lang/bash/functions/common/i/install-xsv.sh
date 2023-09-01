#!/usr/bin/env bash

koopa_install_xsv() {
    koopa_install_app \
        --installer='rust-package' \
        --name='xsv' \
        "$@"
}
