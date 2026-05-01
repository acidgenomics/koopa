#!/usr/bin/env bash

main() {
    # """
    # Install mpdecimal.
    # @note Updated 2023-04-12.
    # """
    local -A dict
    local -a conf_args
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    conf_args=(
        '--disable-static'
        "--prefix=${dict['prefix']}"
    )
    dict['url']="https://www.bytereef.org/software/mpdecimal/releases/\
mpdecimal-${dict['version']}.tar.gz"
    _koopa_download "${dict['url']}"
    _koopa_extract "$(_koopa_basename "${dict['url']}")" 'src'
    _koopa_cd 'src'
    _koopa_make_build "${conf_args[@]}"
    _koopa_rm "${dict['prefix']}/lib/"*'.a'
    return 0
}
