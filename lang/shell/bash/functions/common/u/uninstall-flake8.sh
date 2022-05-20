#!/usr/bin/env bash

koopa_uninstall_flake8() {
    koopa_uninstall_app \
        --name='flake8' \
        --unlink-in-bin='flake8' \
        "$@"
}
