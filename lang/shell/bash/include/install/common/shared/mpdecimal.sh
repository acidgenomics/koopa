#!/usr/bin/env bash

main() {
    # """
    # Install mpdecimal.
    # @note Updated 2023-04-06.
    # """
    local -A dict
    local -a conf_args
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    conf_args=("--prefix=${dict['prefix']}")
    dict['url']="https://www.bytereef.org/software/mpdecimal/releases/\
mpdecimal-${dict['version']}.tar.gz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    koopa_make_build "${conf_args[@]}"
    return 0
}
