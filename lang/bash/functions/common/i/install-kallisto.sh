#!/usr/bin/env bash

koopa_install_kallisto() {
    koopa_install_app \
        --installer='conda-package' \
        --name='kallisto' \
        "$@"
}
