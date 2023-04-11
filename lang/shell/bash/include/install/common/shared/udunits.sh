#!/usr/bin/env bash

main() {
    # """
    # Install udunits.
    # @note Updated 2023-04-11.
    # """
    local -A dict
    local -a conf_args
    koopa_activate_app 'expat'
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    conf_args=(
        '--disable-static'
        "--prefix=${dict['prefix']}"
    )
    dict['url']="https://artifacts.unidata.ucar.edu/repository/\
downloads-udunits/${dict['version']}/udunits-${dict['version']}.tar.gz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    koopa_make_build "${conf_args[@]}"
    return 0
}
