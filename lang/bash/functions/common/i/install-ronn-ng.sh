#!/usr/bin/env bash

koopa_install_ronn_ng() {
    koopa_install_app \
        --installer='ruby-package' \
        --name='ronn-ng' \
        "$@"
}
