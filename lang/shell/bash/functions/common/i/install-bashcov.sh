#!/usr/bin/env bash

koopa_install_bashcov() {
    koopa_install_app \
        --installer='ruby-package' \
        --link-in-bin='bin/bashcov' \
        --name='bashcov' \
        "$@"
}
