#!/usr/bin/env bash

koopa_install_gawk() {
    koopa_install_app \
        --installer='gnu-app' \
        --activate-opt='gettext' \
        --activate-opt='mpfr' \
        --activate-opt='readline' \
        --link-in-bin='bin/awk' \
        --name='gawk' \
        "$@"
}
