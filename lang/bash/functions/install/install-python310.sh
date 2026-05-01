#!/usr/bin/env bash

_koopa_install_python310() {
    _koopa_install_app \
        --installer='python' \
        --name='python3.10' \
        "$@"
}
