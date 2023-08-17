#!/usr/bin/env bash

main() {
    # """
    # Install libconfig.
    # @note Updated 2023-08-17.
    #
    # @seealso
    # - https://github.com/hyperrealm/libconfig
    # - https://formulae.brew.sh/formula/libconfig
    # """
    local -a conf_args
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    conf_args=(
        '--disable-dependency-tracking'
        "--prefix=${dict['prefix']}"
    )
    dict['url']="https://github.com/hyperrealm/libconfig/releases/download/\
v${dict['version']}/libconfig-${dict['version']}.tar.gz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    koopa_make_build "${conf_args[@]}"
    return 0
}
