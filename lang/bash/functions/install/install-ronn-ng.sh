#!/usr/bin/env bash

_koopa_install_ronn_ng() {
    _koopa_install_app \
        --installer='ruby-package' \
        --name='ronn-ng' \
        "$@"
}
