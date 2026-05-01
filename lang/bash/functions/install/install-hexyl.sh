#!/usr/bin/env bash

_koopa_install_hexyl() {
    _koopa_install_app \
        --installer='rust-package' \
        --name='hexyl' \
        "$@"
}
