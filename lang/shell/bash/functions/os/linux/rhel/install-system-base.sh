#!/usr/bin/env bash

koopa_rhel_install_system_base() {
    koopa_install_app \
        --name-fancy='Red Hat Enterprise Linux (RHEL) base system' \
        --name='base' \
        --platform='rhel' \
        --system \
        "$@"
}
