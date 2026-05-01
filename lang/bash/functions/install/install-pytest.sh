#!/usr/bin/env bash

_koopa_install_pytest() {
    _koopa_install_app \
        --installer='python-package' \
        --name='pytest' \
        -D --extra-package='pytest-cov' \
        "$@"
}
