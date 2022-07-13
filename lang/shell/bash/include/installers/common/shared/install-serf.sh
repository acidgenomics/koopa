#!/usr/bin/env bash

main() {
    # """
    # Install Apache Serf.
    # @note Updated 2022-07-12.
    #
    # Required by subversion for HTTPS connections.
    #
    # @seealso
    # - https://serf.apache.org/download
    # - https://www.linuxfromscratch.org/blfs/view/svn/basicnet/serf.html
    # - https://github.com/apache/serf/blob/trunk/README
    # - https://raw.githubusercontent.com/Homebrew/homebrew-core/
    #     0c3d786402ad7d9dd5eb6907e3ed3f2525a0472d/Formula/subversion.rb
    # """
    local app dict scons_args
    koopa_assert_has_no_args "$#"
    koopa_activate_build_opt_prefix 'patch'
    if koopa_is_linux
    then
        koopa_activate_opt_prefix 'zlib'
    fi
    koopa_activate_opt_prefix \
        'apr' \
        'apr-util' \
        'openssl3' \
        'scons'
    declare -A app=(
        [patch]="$(koopa_locate_patch)"
        [scons]="$(koopa_locate_scons)"
        [sed]="$(koopa_locate_sed)"
    )
    declare -A dict=(
        [name]='serf'
        [opt_prefix]="$(koopa_opt_prefix)"
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    dict[file]="${dict[name]}-${dict[version]}.tar.bz2"
    dict[url]="https://www.apache.org/dist/${dict[name]}/${dict[file]}"
    koopa_download "${dict[url]}" "${dict[file]}"
    koopa_extract "${dict[file]}"
    koopa_cd "${dict[name]}-${dict[version]}"
    # Download patch required for OpenSSL 3 compatibility.
    koopa_download "https://www.linuxfromscratch.org/patches/blfs/svn/\
serf-1.3.9-openssl3_fixes-1.patch"
    "${app[patch]}" -Np1 -i 'serf-1.3.9-openssl3_fixes-1.patch'
    # These steps require GNU sed.
    # Alternatively, can consider using Perl approach here instead.
    "${app[sed]}" -i.bak "/Append/s:RPATH=libdir,::" 'SConstruct'
    "${app[sed]}" -i.bak "/Default/s:lib_static,::"  'SConstruct'
    "${app[sed]}" -i.bak "/Alias/s:install_static,::" 'SConstruct'
    "${app[sed]}" -i.bak "/  print/{s/print/print(/; s/$/)/}" 'SConstruct'
    "${app[sed]}" -i.bak "/get_contents()/s/,/.decode()&/" 'SConstruct'
    # NOTE Refer to 'SConstruct' file for supported arguments.
    scons_args=(
        "APR=${dict[opt_prefix]}/apr"
        "APU=${dict[opt_prefix]}/apr-util"
        'CC=gcc'
        "CFLAGS=${CFLAGS:-}"
        'GSSAPI=/usr'
        "LINKFLAGS=${LDFLAGS:-}"
        "OPENSSL=${dict[opt_prefix]}/openssl3"
        "PREFIX=${dict[prefix]}"
    )
    if koopa_is_linux
    then
        scons_args+=(
            # FIXME CC
            # FIXME CFLAGS
            # FIXME CPPFLAGS
            # FIXME LIBS
            # FIXME LINKFLAGS
            "DEBUG=true"
            "ZLIB=${dict[opt_prefix]}/zlib"
        )
    fi
    "${app[scons]}" "${scons_args[@]}"
    "${app[scons]}" "${scons_args[@]}" install
    return 0
}
