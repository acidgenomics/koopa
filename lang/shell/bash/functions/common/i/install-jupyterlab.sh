#!/usr/bin/env bash

koopa_install_jupyterlab() {
    koopa_install_app \
        --installer='conda-env' \
        --link-in-bin='jupyter-lab' \
        --name='jupyterlab' \
        "$@"
}
