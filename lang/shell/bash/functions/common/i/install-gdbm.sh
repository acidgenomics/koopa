#!/usr/bin/env bash

# FIXME Break out to separate installer. Don't use '--activate-opt' here, as
# it can cause issues with binary package install.

koopa_install_gdbm() {
    koopa_install_app \
        --installer='gnu-app' \
        --activate-opt='readline' \
        --name='gdbm' \
        "$@"
}
