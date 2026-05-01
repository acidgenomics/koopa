#!/usr/bin/env bash

main() {
    # """
    # Install krb5.
    # @note Updated 2023-05-26.
    #
    # @seealso
    # - https://formulae.brew.sh/formula/krb5
    # - https://github.com/conda-forge/krb5-feedstock
    # """
    local -A dict
    local -a conf_args
    _koopa_activate_app --build-only 'bison' 'pkg-config'
    _koopa_activate_app 'libedit' 'openssl'
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['maj_min_ver']="$(_koopa_major_minor_version "${dict['version']}")"
    dict['url']="https://kerberos.org/dist/krb5/${dict['maj_min_ver']}/\
krb5-${dict['version']}.tar.gz"
    _koopa_download "${dict['url']}"
    _koopa_extract "$(_koopa_basename "${dict['url']}")" 'krb5'
    _koopa_cd 'krb5/src'
    conf_args=(
        '--disable-nls'
        "--prefix=${dict['prefix']}"
        '--with-crypto-impl=openssl'
        '--with-libedit'
        '--without-keyutils'
        '--without-readline'
        '--without-system-verto'
    )
    _koopa_make_build "${conf_args[@]}"
    return 0
}
