#!/usr/bin/env bash

koopa_install_ipython() {
    koopa_install_app \
        --installer='python-venv' \
        --link-in-bin='bin/ipython' \
        --name-fancy='IPython' \
        --name='ipython' \
        "$@"
}
