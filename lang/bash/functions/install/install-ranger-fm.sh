#!/usr/bin/env bash

_koopa_install_ranger_fm() {
    _koopa_install_app \
        --installer='conda-package' \
        --name='ranger-fm' \
        "$@"
}
