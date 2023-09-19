#!/usr/bin/env bash

koopa_install_bandwhich() {
    koopa_install_app \
        --installer='rust-package' \
        --name='bandwhich' \
        "$@"
}
