#!/usr/bin/env bash

koopa_uninstall_postgresql() {
    koopa_uninstall_app \
        --name='postgresql' \
        "$@"
}
