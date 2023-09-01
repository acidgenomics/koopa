#!/usr/bin/env bash

koopa_install_gseapy() {
    koopa_install_app \
        --installer='python-package' \
        --name='gseapy' \
        "$@"
}
