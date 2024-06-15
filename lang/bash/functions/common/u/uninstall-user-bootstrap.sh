#!/usr/bin/env bash

koopa_uninstall_user_bootstrap() {
    koopa_uninstall_app \
        --name='bootstrap' \
        --prefix="$(koopa_bootstrap_prefix)" \
        --user \
        "$@"
}
