#!/usr/bin/env bash

koopa_install_rbenv() {
    koopa_install_app \
        --link-in-bin='bin/rbenv' \
        --name='rbenv' \
        "$@"
}
