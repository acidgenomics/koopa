#!/usr/bin/env bash

koopa_install_ipython() {
    koopa_install_app \
        --link-in-bin='ipython' \
        --name='ipython' \
        "$@"
}
