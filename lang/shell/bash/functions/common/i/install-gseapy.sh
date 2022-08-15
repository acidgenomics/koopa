#!/usr/bin/env bash

koopa_install_gseapy() {
    koopa_install_app \
        --link-in-bin='gseapy' \
        --name='gseapy' \
        "$@"
}
