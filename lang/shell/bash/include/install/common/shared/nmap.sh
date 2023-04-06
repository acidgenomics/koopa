#!/usr/bin/env bash

main() {
    # """
    # Install nmap.
    # @note Updated 2023-04-06.
    #
    # Attempting to bundle zlib fails on Ubuntu.
    # Attempting to bundle pcre fails on macOS.
    #
    # May need to include libcap and liblinear here.
    #
    # @seealso
    # - https://nmap.org/
    # - https://svn.nmap.org/nmap/
    # - https://github.com/Homebrew/homebrew-core/blob/HEAD/Formula/nmap.rb
    # - https://git.alpinelinux.org/aports/tree/main/nmap/APKBUILD
    # - Check supported Lua version at:
    #   https://github.com/nmap/nmap/tree/master/liblua
    # """
    local -A app dict 
    local -a conf_args deps
    koopa_activate_app --build-only \
        'bison' \
        'flex' \
        'make'
    deps=(
        'zlib'
        'openssl3'
        # > 'libssh2'
        'pcre'
        # > 'lua'
    )
    koopa_activate_app "${deps[@]}"
    app['make']="$(koopa_locate_make)"
    koopa_assert_is_executable "${app[@]}"
    dict['jobs']="$(koopa_cpu_count)"
    # > dict['libssh2']="$(koopa_app_prefix 'libssh2')"
    # > dict['lua']="$(koopa_app_prefix 'lua')"
    dict['name']='nmap'
    dict['openssl']="$(koopa_app_prefix 'openssl3')"
    dict['pcre']="$(koopa_app_prefix 'pcre')"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['zlib']="$(koopa_app_prefix 'zlib')"
    dict['file']="${dict['name']}-${dict['version']}.tar.bz2"
    dict['url']="https://nmap.org/dist/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd "${dict['name']}-${dict['version']}"
    conf_args=(
        # > '--disable-universal'
        "--prefix=${dict['prefix']}"
        '--with-libdnet=included'
        '--with-liblinear=included'
        # > "--with-liblua=${dict['lua']}"
        '--with-liblua=included'
        # NOTE May only want to link PCRE on macOS.
        # > '--with-libpcap=included'
        "--with-libpcre=${dict['pcre']}"
        '--with-libpcre=included'
        # > "--with-libssh2=${dict['libssh2']}"
        '--with-libssh2=included'
        "--with-libz=${dict['zlib']}"
        # > '--with-libz=included'
        "--with-openssl=${dict['openssl']}"
        # > '--without-ncat'
        # > '--without-ndiff'
        # > '--without-nmap-update'
        # > '--without-nping'
        '--without-zenmap'
    )
    koopa_print_env
    koopa_dl 'configure args' "${conf_args[*]}"
    ./configure --help
    ./configure "${conf_args[@]}"
    "${app['make']}" VERBOSE=1 --jobs="${dict['jobs']}"
    "${app['make']}" install
    return 0
}
