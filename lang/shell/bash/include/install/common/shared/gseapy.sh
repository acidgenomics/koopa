#!/usr/bin/env bash

main() {
    koopa_install_app_subshell \
        --installer='conda-env' \
        --name='gseapy' \
        "$@"
}
