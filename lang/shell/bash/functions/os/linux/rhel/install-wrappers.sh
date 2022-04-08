#!/usr/bin/env bash

# System ================================================================== {{{1

# base-system ------------------------------------------------------------- {{{2

koopa_rhel_install_base_system() { # {{{3
    koopa_install_app \
        --name-fancy='Red Hat Enterprise Linux (RHEL) base system' \
        --name='install-base' \
        --platform='rhel' \
        --system \
        "$@"
}
