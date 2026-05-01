#!/usr/bin/env bash

_koopa_install_httpie() {
    _koopa_install_app \
        --installer='python-package' \
        --name='httpie' \
        "$@"
}
