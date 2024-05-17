#!/usr/bin/env bash

main() {
    # """
    # Install PostgreSQL.
    # @note 2024-05-17.
    #
    # @seealso
    # - https://formulae.brew.sh/formula/postgresql@16
    # - https://formulae.brew.sh/formula/postgresql@14
    # """
    local -A dict
    local -a deps
    deps+=(
        'icu4c'
        'libxml2'
        'libxslt'
        'lz4'
        'openssl3'
        'perl'
        'readline'
    )
    koopa_activate_app --build-only 'pkg-config'
    koopa_activate_app "${deps[@]}"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    conf_args=(
        "--prefix=${dict['prefix']}"
        '--disable-debug'
        '--enable-thread-safety'
        '--with-icu'
        '--with-libxml'
        '--with-libxslt'
        '--with-lz4'
        '--with-openssl'
        '--with-perl'
        '--without-gssapi'
        '--without-ldap'
        '--without-pam'
    )
    dict['url']="https://ftp.postgresql.org/pub/source/v${dict['version']}/\
postgresql-${dict['version']}.tar.bz2"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    koopa_make_build "${conf_args[@]}"
    return 0
}
