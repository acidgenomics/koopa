#!/usr/bin/env bash

koopa_uninstall_openblas() {
    koopa_uninstall_app \
        --name-fancy='OpenBLAS' \
        --name='openblas' \
        "$@"
}
