#!/usr/bin/env bash

koopa_install_difftastic() {
    koopa_install_app \
        --link-in-bin='bin/difft' \
        --name='difftastic' \
        --installer='rust-package' \
        "$@"
}
