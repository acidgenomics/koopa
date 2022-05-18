#!/usr/bin/env bash

koopa_install_procs() {
    koopa_install_app \
        --link-in-bin='bin/procs' \
        --name='procs' \
        --installer='rust-package' \
        "$@"
}
