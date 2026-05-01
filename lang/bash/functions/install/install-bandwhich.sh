#!/usr/bin/env bash

_koopa_install_bandwhich() {
    _koopa_install_app \
        --installer='rust-package' \
        --name='bandwhich' \
        "$@"
}
