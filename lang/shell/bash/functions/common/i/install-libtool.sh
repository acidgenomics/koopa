#!/usr/bin/env bash

# FIXME Break out to separate installer. Don't use '--activate-opt' here, as
# it can cause issues with binary package install.

koopa_install_libtool() {
    koopa_install_app \
        --activate-opt='m4' \
        --installer='gnu-app' \
        --link-in-bin='libtool' \
        --link-in-bin='libtoolize' \
        --name='libtool' \
        "$@"
    # These links are useful for compiling vterm inside of Emacs. Current
    # make formula only looks for 'glibtool'.
    (
        koopa_cd "$(koopa_bin_prefix)"
        koopa_ln 'libtool' 'glibtool'
        koopa_ln 'libtoolize' 'glibtoolize'
    )
}
