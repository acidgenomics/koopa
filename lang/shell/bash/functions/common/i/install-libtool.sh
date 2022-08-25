#!/usr/bin/env bash

# FIXME Do this this in the main installer and link from there instead.

koopa_install_libtool() {
    # """
    # These links are useful for compiling vterm inside of Emacs. Current
    # make formula only looks for 'glibtool'.
    # """
    koopa_install_app \
        --name='libtool' \
        "$@"
    (
        koopa_cd "$(koopa_bin_prefix)"
        koopa_ln 'libtool' 'glibtool'
        koopa_ln 'libtoolize' 'glibtoolize'
    )
}
