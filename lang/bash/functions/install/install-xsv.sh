#!/usr/bin/env bash

_koopa_install_xsv() {
    _koopa_install_app \
        --installer='conda-package' \
        --name='xsv' \
        "$@"
}
