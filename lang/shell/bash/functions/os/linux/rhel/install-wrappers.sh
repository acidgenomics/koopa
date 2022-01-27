#!/usr/bin/env bash

koopa::rhel_install_base_system() { # {{{1
    koopa::install_app \
        --name-fancy='Red Hat Enterprise Linux (RHEL) base system' \
        --name='install-base' \
        --platform='rhel' \
        --system \
        "$@"
}
