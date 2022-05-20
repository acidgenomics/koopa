#!/usr/bin/env bash

koopa_install_delta() {
    koopa_install_app \
        --link-in-bin='bin/delta' \
        --name='delta' \
        --installer='rust-package' \
        "$@"
}
