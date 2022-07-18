#!/usr/bin/env bash

koopa_install_ipython() {
    koopa_install_app \
        --installer='python-venv' \
        --link-in-bin='ipython' \
        --name='ipython' \
        "$@"
}
