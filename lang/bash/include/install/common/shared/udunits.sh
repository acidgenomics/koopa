#!/usr/bin/env bash

main() {
    # """
    # Install udunits.
    # @note Updated 2026-01-02.
    # """
    local -A dict
    local -a conf_args
    _koopa_activate_app 'expat'
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    conf_args=(
        '--disable-static'
        "--prefix=${dict['prefix']}"
    )
    dict['url']="https://downloads.unidata.ucar.edu/udunits/\
${dict['version']}/udunits-${dict['version']}.tar.gz"
    _koopa_download "${dict['url']}"
    _koopa_extract "$(_koopa_basename "${dict['url']}")" 'src'
    _koopa_cd 'src'
    _koopa_make_build "${conf_args[@]}"
    return 0
}
