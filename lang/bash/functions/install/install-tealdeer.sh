#!/usr/bin/env bash

_koopa_install_tealdeer() {
    _koopa_install_app \
        --installer='conda-package' \
        --name='tealdeer' \
        "$@"
}
