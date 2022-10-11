#!/usr/bin/env bash

koopa_uninstall_openjdk() {
    koopa_uninstall_app \
        --name='openjdk' \
        "$@"
}
