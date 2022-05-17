#!/usr/bin/env bash

koopa_configure_ruby() {
    koopa_configure_app_packages \
        --name-fancy='Ruby' \
        --name='ruby' \
        "$@"
}
