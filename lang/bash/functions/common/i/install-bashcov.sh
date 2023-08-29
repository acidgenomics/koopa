#!/usr/bin/env bash

koopa_install_bashcov() {
    koopa_install_app \
        --installer='ruby-package' \
        --name='bashcov' \
        "$@"
}
