#!/usr/bin/env bash

koopa_install_jupyterlab() {
    koopa_install_app \
        --installer='python-package' \
        --name='jupyterlab' \
        "$@"
}
