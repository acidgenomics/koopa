#!/usr/bin/env bash

main() {
    # """
    # Install screen.
    # @note Updated 2023-10-19.
    #
    # Currently fails to build on macOS using system clang.
    #
    # @seealso
    # - https://github.com/conda-forge/screen-feedstock
    # - https://formulae.brew.sh/formula/screen
    # - https://ports.macports.org/port/screen/
    # """
    local -A dict
    local -a conf_args
    koopa_activate_app --build-only 'autoconf' 'automake'
    koopa_activate_app 'libxcrypt' 'ncurses'
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['url']="$(koopa_gnu_mirror_url)/screen/\
screen-${dict['version']}.tar.gz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    if koopa_is_macos
    then
        # Fix error: dereferencing pointer to incomplete type 'struct utmp'.
        koopa_append_cflags '-include utmp.h'
        # Fix for Xcode 12 build errors.
        # https://savannah.gnu.org/bugs/index.php?59465
        koopa_append_cflags '-Wno-implicit-function-declaration'
    fi
    conf_args=(
        # > '--enable-colors256'
        # > '--enable-pam'
        # > '--enable-rxvt_osc'
        # > '--enable-telnet'
        "--prefix=${dict['prefix']}"
    )
    ./autogen.sh
    koopa_make_build "${conf_args[@]}"
    return 0
}
