#!/usr/bin/env bash

koopa_install_ipython() {
    koopa_install_app \
        --installer='python-package' \
        --name='ipython' \
        "$@"
}
