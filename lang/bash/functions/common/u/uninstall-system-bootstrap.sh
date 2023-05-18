#!/usr/bin/env bash

koopa_uninstall_system_bootstrap() {
    koopa_uninstall_app \
        --name='bootstrap' \
        --system \
        "$@"
}
