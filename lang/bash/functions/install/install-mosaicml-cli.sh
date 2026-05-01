#!/usr/bin/env bash

_koopa_install_mosaicml_cli() {
    _koopa_install_app \
        --installer='python-package' \
        --name='mosaicml-cli' \
        "$@"
}
