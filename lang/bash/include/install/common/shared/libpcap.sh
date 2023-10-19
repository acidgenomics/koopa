#!/usr/bin/env bash

main() {
    # """
    # Install libpcap.
    # @note Updated 2023-10-19.
    #
    # @seealso
    # - https://www.tcpdump.org/
    # - https://formulae.brew.sh/formula/libpcap
    # """
    local -A dict
    local -a conf_args
    koopa_activate_app --build-only 'bison' 'flex' 'pkg-config'
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['url']="https://www.tcpdump.org/release/\
libpcap-${dict['version']}.tar.gz"
    conf_args+=(
        # > '--disable-universal'
        '--enable-ipv6'
        "--prefix=${dict['prefix']}"
    )
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    koopa_make_build "${conf_args[@]}"
    return 0
}
