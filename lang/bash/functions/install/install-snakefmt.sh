#!/usr/bin/env bash

_koopa_install_snakefmt() {
    _koopa_install_app \
        --installer='python-package' \
        --name='snakefmt' \
        "$@"
}
