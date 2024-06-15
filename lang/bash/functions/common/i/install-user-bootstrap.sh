#!/usr/bin/env bash

koopa_install_user_bootstrap() {
    koopa_install_app \
        --name='bootstrap' \
        --user \
        "$@"
}
