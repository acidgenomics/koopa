#!/usr/bin/env bash

koopa_configure_julia() {
    koopa_configure_app_packages \
        --name-fancy='Julia' \
        --name='julia' \
        "$@"
}
