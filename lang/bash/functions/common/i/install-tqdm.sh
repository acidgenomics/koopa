#!/usr/bin/env bash

koopa_install_tqdm() {
    koopa_install_app \
        --installer='python-package' \
        --name='tqdm' \
        "$@"
}
