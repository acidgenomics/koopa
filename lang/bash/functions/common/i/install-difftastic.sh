#!/usr/bin/env bash

koopa_install_difftastic() {
    koopa_install_app \
        --installer='rust-package' \
        --name='difftastic' \
        "$@"
}
