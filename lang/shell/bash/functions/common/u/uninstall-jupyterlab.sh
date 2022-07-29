#!/usr/bin/env bash

koopa_uninstall_jupyterlab() {
    koopa_uninstall_app \
        --name='jupyterlab' \
        --unlink-in-bin='jupyterlab' \
        "$@"
}
