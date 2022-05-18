#!/usr/bin/env bash

koopa_install_openblas() {
    koopa_install_app \
        --name-fancy='OpenBLAS' \
        --name='openblas' \
        "$@"
}
