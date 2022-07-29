#!/usr/bin/env bash

koopa_install_jupyterlab() {
    koopa_install_app \
        --installer='conda-env' \
        --link-in-bin='jupyterlab' \
        --name='jupyterlab' \
        "$@"
}
