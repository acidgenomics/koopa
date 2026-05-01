#!/usr/bin/env bash

_koopa_install_ipython() {
    _koopa_install_app \
        --installer='python-package' \
        --name='ipython' \
        "$@"
}
