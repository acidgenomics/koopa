#!/usr/bin/env bash

koopa_uninstall_serf() {
    koopa_uninstall_app \
        --name-fancy='Apache Serf' \
        --name='serf' \
        "$@"
}
