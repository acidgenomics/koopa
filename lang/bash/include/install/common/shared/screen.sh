#!/usr/bin/env bash

# FIXME Hitting this error on macOS:
# configure: checking select with  -lnet -lnsl...
# > configure: error: !!! no select - no screen

main() {
    # """
    # Install screen.
    # @note Updated 2023-05-23.
    #
    # @seealso
    # - https://github.com/conda-forge/screen-feedstock
    # - https://formulae.brew.sh/formula/screen
    # - https://ports.macports.org/port/screen/
    # """
    local -A dict
    local -a 
    koopa_activate_app --build-only 'autoconf' 'automake'
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['url']="$(koopa_gnu_mirror_url)/screen/\
screen-${dict['version']}.tar.gz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    CFLAGS="${CFLAGS:-}"
    # > CFLAGS="-DRUN_LOGIN ${CFLAGS:-}"
    # > CFLAGS="-Wno-implicit-function-declaration ${CFLAGS:-}"
    # > CFLAGS="-include utmp.h ${CFLAGS:-}"
    export CFLAGS
    conf_args=(
        # > '--enable-pam'
        # > '--enable-rxvt_osc'
        # > '--enable-telnet'
        '--enable-colors256'
        "--prefix=${dict['prefix']}"
    )
    ./autogen.sh
    koopa_make_build "${conf_args[@]}"
    return 0
}
