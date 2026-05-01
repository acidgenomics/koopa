#!/usr/bin/env bash

_koopa_install_csvkit() {
    _koopa_install_app \
        --installer='python-package' \
        --name='csvkit' \
        "$@"
}
