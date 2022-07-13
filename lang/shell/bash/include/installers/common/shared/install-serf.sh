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
    if koopa_is_linux
    then
        koopa_activate_opt_prefix 'zlib'
    fi
    koopa_activate_opt_prefix \
        'apr' \
        'apr-util' \
        'openssl1' \
        'scons'
    declare -A app=(
        [scons]="$(koopa_locate_scons)"
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
    koopa_find_and_replace_in_file \
        --fixed \
        --pattern="print 'Warning: Used unknown variables:', ', '.join(unknown.keys())" \
        --replacement="print('Warning: Used unknown variables:', ', '.join(unknown.keys()))" \
        'SConstruct'
    koopa_find_and_replace_in_file \
        --fixed \
        --pattern='variables=opts,' \
        --replacement="variables=opts, RPATHPREFIX = '-Wl,-rpath,'," \
        'SConstruct'
    if koopa_is_linux
    then
        koopa_find_and_replace_in_file \
            --fixed \
            --pattern="env.Append(LIBPATH=['\$OPENSSL/lib'])" \
            --replacement="env.Append(LIBPATH=['\$OPENSSL/lib'])\nenv.Append(CPPPATH=['\$ZLIB/include'])\nenv.Append(LIBPATH=['\$ZLIB/lib'])" \
            'SConstruct'
    fi
    koopa_stop "${PWD} FIXME"

    # NOTE Refer to 'SConstruct' file for supported arguments.
    scons_args=(
        "APR=${dict[opt_prefix]}/apr"
        "APU=${dict[opt_prefix]}/apr-util"
        # > 'CC=gcc'
        "CFLAGS=${CFLAGS:-}"
        # > "LIBS=${LD_LIBRARY_PATH:-}"
        'LIBDIR=lib'
        "LINKFLAGS=${LDFLAGS:-}"
        "OPENSSL=${dict[opt_prefix]}/openssl1"
        "PREFIX=${dict[prefix]}"
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
