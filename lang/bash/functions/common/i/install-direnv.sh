#!/usr/bin/env bash

koopa_install_direnv() {
    koopa_install_app \
        --installer='conda-package' \
        --name='direnv' \
        "$@"
}
