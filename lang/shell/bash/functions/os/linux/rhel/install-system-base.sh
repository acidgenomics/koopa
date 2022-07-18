#!/usr/bin/env bash

koopa_rhel_install_system_base() {
    koopa_install_app \
        --name='base' \
        --platform='rhel' \
        --system \
        "$@"
}
