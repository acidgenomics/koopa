#!/usr/bin/env bash

koopa_uninstall_go_packages() {
    koopa_uninstall_app \
        --name-fancy='Go packages' \
        --name='go-packages' \
        "$@"
}
