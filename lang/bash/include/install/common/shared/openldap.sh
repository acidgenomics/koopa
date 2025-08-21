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
    koopa_activate_app --build-only 'groff'
    koopa_activate_app 'openssl'
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
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    koopa_make_build "${conf_args[@]}"
    return 0
}
