#!/usr/bin/env bash

koopa_uninstall_difftastic() {
    koopa_uninstall_app \
        --name='difftastic' \
        --unlink-in-bin='difft' \
        "$@"
}
