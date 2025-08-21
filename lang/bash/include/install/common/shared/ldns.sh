#!/usr/bin/env bash

main() {
    # """
    # Install ldns.
    # @note Updated 2023-05-26.
    #
    # @seealso
    # - https://www.nlnetlabs.nl/projects/ldns/about/
    # - https://formulae.brew.sh/formula/ldns
    # """
    local -A dict
    local -a conf_args
    koopa_activate_app 'openssl'
    dict['openssl']="$(koopa_app_prefix 'openssl')"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['url']="https://nlnetlabs.nl/downloads/ldns/\
ldns-${dict['version']}.tar.gz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    conf_args=(
        "--prefix=${dict['prefix']}"
        "--with-ssl=${dict['openssl']}"
        '--without-drill'
        '--without-examples'
        '--without-pyldns'
        '--without-pyldnsx'
        '--without-xcode-sdk'
    )
    koopa_make_build "${conf_args[@]}"
    return 0
}
