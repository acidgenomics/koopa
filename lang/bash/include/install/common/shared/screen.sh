#!/usr/bin/env bash

main() {
    # """
    # Install screen.
    # @note Updated 2023-05-23.
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
    CFLAGS="-include utmp.h -Wno-implicit-function-declaration ${CFLAGS:-}"
    export CFLAGS
    conf_args=(
        '--enable-colors256'
        '--enable-pam'
        "--prefix=${dict['prefix']}"
    )
    ./autogen.sh
    koopa_make_build "${conf_args[@]}"
    return 0
}
