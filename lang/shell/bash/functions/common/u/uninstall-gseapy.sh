#!/usr/bin/env bash

koopa_uninstall_gseapy() {
    koopa_uninstall_app \
        --name='gseapy' \
        --unlink-in-bin='gseapy' \
        "$@"
}
