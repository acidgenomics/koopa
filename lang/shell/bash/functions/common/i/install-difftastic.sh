#!/usr/bin/env bash

koopa_install_difftastic() {
    koopa_install_app \
        --link-in-bin='difft' \
        --name='difftastic' \
        "$@"
}
