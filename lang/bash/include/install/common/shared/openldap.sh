#!/usr/bin/env bash

main() {
    # """
    # Install openldap.
    # @note Updated 2023-08-31.
    #
    # @seealso
    # - https://formulae.brew.sh/formula/openldap
    # """
    local -A dict
    local -a conf_args
    _koopa_activate_app --build-only 'groff'
    _koopa_activate_app 'openssl'
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    conf_args=(
        # > --localstatedir=#{var}
        # > --sysconfdir=#{etc}
        '--disable-dependency-tracking'
        '--enable-accesslog'
        '--enable-auditlog'
        '--enable-bdb=no'
        '--enable-constraint'
        '--enable-dds'
        '--enable-deref'
        '--enable-dyngroup'
        '--enable-dynlist'
        '--enable-hdb=no'
        '--enable-memberof'
        '--enable-ppolicy'
        '--enable-proxycache'
        '--enable-refint'
        '--enable-retcode'
        '--enable-seqmod'
        '--enable-translucent'
        '--enable-unique'
        '--enable-valsort'
        "--prefix=${dict['prefix']}"
        '--without-systemd'
    )
    dict['url']="https://www.openldap.org/software/download/OpenLDAP/\
openldap-release/openldap-${dict['version']}.tgz"
    _koopa_download "${dict['url']}"
    _koopa_extract "$(_koopa_basename "${dict['url']}")" 'src'
    _koopa_cd 'src'
    # Fix OpenSSL 4 compatibility: ASN1_STRING is now fully opaque.
    # Use accessor functions instead of direct struct member access.
    _koopa_find_and_replace_in_file \
        --pattern='cn->length' \
        --replacement='ASN1_STRING_length(cn)' \
        'libraries/libldap/tls_o.c'
    _koopa_find_and_replace_in_file \
        --pattern='cn->data' \
        --replacement='ASN1_STRING_get0_data(cn)' \
        'libraries/libldap/tls_o.c'
    _koopa_make_build "${conf_args[@]}"
    return 0
}
