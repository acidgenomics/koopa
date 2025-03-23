#!/usr/bin/env bash

koopa_install_httpie() {
    koopa_install_app \
        --installer='python-package' \
        --name='httpie' \
        "$@"
}
