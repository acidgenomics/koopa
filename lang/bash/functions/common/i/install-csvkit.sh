#!/usr/bin/env bash

koopa_install_csvkit() {
    koopa_install_app \
        --installer='python-package' \
        --name='csvkit' \
        "$@"
}
