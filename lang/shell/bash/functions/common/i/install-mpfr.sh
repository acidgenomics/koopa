#!/usr/bin/env bash

# FIXME Break out to separate installer. Don't use '--activate-opt' here, as
# it can cause issues with binary package install.

koopa_install_mpfr() {
    koopa_install_app \
        --activate-opt='gmp' \
        --installer='gnu-app' \
        --name='mpfr' \
        "$@"
}
