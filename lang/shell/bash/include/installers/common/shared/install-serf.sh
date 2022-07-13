#!/usr/bin/env bash

# FIXME Can we use CMake here instead with CMakeList.txt reference?
# FIXME Failing to locate 'zlib.h' inside of Ubuntu here.

main() {
    # """
    # Install Apache Serf.
    # @note Updated 2022-07-12.
    #
    # Required by subversion for HTTPS connections.
    #
    # @seealso
    # - https://serf.apache.org/download
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/
    #     subversion.rb
    # - https://www.linuxfromscratch.org/blfs/view/svn/basicnet/serf.html
    # - https://github.com/apache/serf/blob/trunk/README
    # - https://fossies.org/diffs/serf/1.3.8_vs_1.3.9/README-diff.html
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
    # This is modified from Linux From Scratch tutorial article.
    "${app[sed]}" -i.bak "/Append/s:RPATH=libdir,::" 'SConstruct'
    "${app[sed]}" -i.bak "/Default/s:lib_static,::"  'SConstruct'
    "${app[sed]}" -i.bak "/Alias/s:install_static,::" 'SConstruct'
    "${app[sed]}" -i.bak "/  print/{s/print/print(/; s/$/)/}" 'SConstruct'
    "${app[sed]}" -i.bak "/get_contents()/s/,/.decode()&/" 'SConstruct'

    # FIXME May need to apply this approach used by Homebrew.
    # > if koopa_is_linux
    # > then
        # FIXME Need to fix detection of ZLIB.
        # > inreplace "SConstruct" do |s|
        # >   s.gsub! "env.Append(LIBPATH=['$OPENSSL\/lib'])",
        # >   "\\1\nenv.Append(CPPPATH=['$ZLIB\/include'])\nenv.Append(LIBPATH=['$ZLIB/lib'])"
        # > end
    # > fi

    # NOTE Refer to 'SConstruct' file for supported arguments.
    scons_args=(
        "APR=${dict[opt_prefix]}/apr"
        "APU=${dict[opt_prefix]}/apr-util"
        # > 'CC=gcc'
        "CFLAGS=${CFLAGS:-}"
        # > "DEBUG=true"
        # > 'GSSAPI=/usr'
        # > "LIBS=${LD_LIBRARY_PATH:-}"
        'LIBDIR=lib'
        "LINKFLAGS=${LDFLAGS:-}"
        "OPENSSL=${dict[opt_prefix]}/openssl3"
        "PREFIX=${dict[prefix]}"
        "SOURCE_LAYOUT=true"
    )
    if koopa_is_linux
    then
        scons_args+=(
            "ZLIB=${dict[opt_prefix]}/zlib"
        )
    fi
    "${app[scons]}" "${scons_args[@]}"
    "${app[scons]}" "${scons_args[@]}" install
    return 0
}
