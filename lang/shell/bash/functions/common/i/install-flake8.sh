#!/usr/bin/env bash

koopa_install_flake8() {
    koopa_install_app \
        --link-in-bin='flake8' \
        --name='flake8' \
        "$@"
}
