#!/usr/bin/env bash

koopa_install_bioawk() {
    koopa_install_app \
        --installer='conda-package' \
        --name='bioawk' \
        "$@"
}
