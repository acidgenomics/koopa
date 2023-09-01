#!/usr/bin/env bash

koopa_install_colorls() {
    koopa_install_app \
        --installer='ruby-package' \
        --name='colorls' \
        "$@"
}
