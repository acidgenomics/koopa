#!/usr/bin/env bash

# FIXME Need to use RUSTFLAGS to pass these correctly.

# FIXME Hitting this build error on Linux:
#1" "-nodefaultlibs"
#  = note: /usr/bin/ld: cannot find -lxcb: No such file or directory
#          /usr/bin/ld: cannot find -lxcb-render: No such file or directory
#          /usr/bin/ld: cannot find -lxcb-shape: No such file or directory
#          /usr/bin/ld: cannot find -lxcb-xfixes: No such file or directory
#          collect2: error: ld returned 1 exit status

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
        koopa_activate_app --build-only 'python3.11'
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
