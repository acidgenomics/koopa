#!/usr/bin/env bash

koopa_configure_go() {
    koopa_configure_app_packages \
        --name-fancy='Go' \
        --name='go' \
        "$@"
}
