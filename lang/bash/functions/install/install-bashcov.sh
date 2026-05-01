#!/usr/bin/env bash

_koopa_install_bashcov() {
    _koopa_install_app \
        --installer='ruby-package' \
        --name='bashcov' \
        "$@"
}
