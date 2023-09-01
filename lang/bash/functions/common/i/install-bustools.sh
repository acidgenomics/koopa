#!/usr/bin/env bash

koopa_install_bustools() {
    koopa_install_app \
        --installer='conda-package' \
        --name='bustools' \
        "$@"
}
