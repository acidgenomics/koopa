#!/usr/bin/env bash

# FIXME Break out to separate installer. Don't use '--activate-opt' here, as
# it can cause issues with binary package install.

koopa_install_pytaglib() {
    koopa_install_app \
        --link-in-bin='pyprinttags' \
        --activate-opt='taglib' \
        --installer='python-venv' \
        --name='pytaglib' \
        "$@"
}
