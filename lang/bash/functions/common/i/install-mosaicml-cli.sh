#!/usr/bin/env bash

koopa_install_mosaicml_cli() {
    koopa_install_app \
        --installer='python-package' \
        --name='mosaicml-cli' \
        "$@"
}
