#!/usr/bin/env bash

koopa_install_kallisto() {
    koopa_install_app \
        --installer='conda-env' \
        --link-in-bin='bin/kallisto' \
        --name='kallisto' \
        "$@"
}
