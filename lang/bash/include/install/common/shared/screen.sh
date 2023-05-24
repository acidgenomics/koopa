#!/usr/bin/env bash

main() {
    # """
    # Install screen.
    # @note Updated 2023-05-24.
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
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['url']="$(koopa_gnu_mirror_url)/screen/\
screen-${dict['version']}.tar.gz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    CFLAGS="${CFLAGS:-}"
    if koopa_is_macos
    then
        # Fix error: dereferencing pointer to incomplete type 'struct utmp'.
        CFLAGS="${CFLAGS:-} -include utmp.h"
        # Fix for Xcode 12 build errors.
        # https://savannah.gnu.org/bugs/index.php?59465
        CFLAGS="${CFLAGS:-} -Wno-implicit-function-declaration"
    fi
    export CFLAGS
    conf_args=(
        # > '--enable-rxvt_osc'
        # > '--enable-telnet'
        '--enable-pam'
        '--enable-colors256'
        "--prefix=${dict['prefix']}"
    )
    ./autogen.sh
    koopa_make_build "${conf_args[@]}"
    return 0
}
