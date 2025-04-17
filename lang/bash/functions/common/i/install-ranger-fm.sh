#!/usr/bin/env bash

koopa_install_ranger_fm() {
    koopa_install_app \
        --installer='python-package' \
        --name='ranger-fm' \
        "$@"
}
