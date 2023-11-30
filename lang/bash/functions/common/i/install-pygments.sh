#!/usr/bin/env bash

koopa_install_pygments() {
    koopa_install_app \
        --installer='python-package' \
        --name='pygments' \
        "$@"
}
