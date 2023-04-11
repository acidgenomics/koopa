#!/usr/bin/env bash

main() {
    # """
    # Install expat.
    # @note Updated 2023-04-10.
    #
    # @seealso
    # - https://libexpat.github.io/
    # """
    local -A dict
    local -a conf_args
    koopa_activate_app --build-only 'pkg-config'
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['version2']="${dict['version']//./_}"
    conf_args=(
        '--disable-static'
        "--prefix=${dict['prefix']}"
    )
    dict['url']="https://github.com/libexpat/libexpat/releases/download/\
R_${dict['version2']}/expat-${dict['version']}.tar.xz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    koopa_make_build "${conf_args[@]}"
    return 0
}
