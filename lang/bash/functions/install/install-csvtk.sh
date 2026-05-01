#!/usr/bin/env bash

_koopa_install_csvtk() {
    _koopa_install_app \
        --installer='conda-package' \
        --name='csvtk' \
        "$@"
}
