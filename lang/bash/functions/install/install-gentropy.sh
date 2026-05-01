#!/usr/bin/env bash

_koopa_install_gentropy() {
    _koopa_install_app \
        --installer='python-package' \
        --name='gentropy' \
        -D --python-version='3.10' \
        "$@"
}
