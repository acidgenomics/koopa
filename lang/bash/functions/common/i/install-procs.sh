#!/usr/bin/env bash

koopa_install_procs() {
    koopa_install_app \
        --installer='rust-package' \
        --name='procs' \
        "$@"
}
