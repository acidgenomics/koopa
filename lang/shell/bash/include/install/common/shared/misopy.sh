#!/usr/bin/env bash

# NOTE This is currently slow to solve.

main() {
    koopa_install_app_subshell \
        --installer='conda-env' \
        --name='misopy' \
        "$@"
}
