#!/usr/bin/env bash

koopa_install_xsra() {
    koopa_install_app \
        --installer='rust-package' \
        --name='xsra' \
        "$@"
}
