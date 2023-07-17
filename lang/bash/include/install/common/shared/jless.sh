#!/usr/bin/env bash

# FIXME This results in shared library issue on Linux argh...this is due
# to RUSTFLAGS not baking in the lib path correctly.

# jless: error while loading shared libraries: libxcb-shape.so.0: cannot open shared object file: No such file or directory

main() {
    # """
    # Install jless.
    # @note Updated 2023-07-17.
    #
    # @seealso
    # - https://formulae.brew.sh/formula/jless
    # """
    if koopa_is_linux
    then
        koopa_activate_app \
            'xorg-xorgproto' \
            'xorg-libxau' \
            'xorg-libxdmcp' \
            'xorg-libxcb'
    fi
    koopa_install_app_subshell \
        --installer='rust-package' \
        --name='jless'
}
