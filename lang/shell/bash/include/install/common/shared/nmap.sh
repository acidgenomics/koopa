#!/usr/bin/env bash

main() {
    # """
    # Install nmap.
    # @note Updated 2022-08-31.
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
    local app conf_args deps dict
    koopa_activate_build_opt_prefix \
        'bison' \
        'flex'
    deps=(
        'zlib'
        'openssl3'
        # > 'libssh2'
        'pcre'
        # > 'lua'
    )
    koopa_activate_opt_prefix "${deps[@]}"
    declare -A app=(
        ['make']="$(koopa_locate_make)"
    )
    [[ -x "${app['make']}" ]] || return 1
    declare -A dict=(
        ['jobs']="$(koopa_cpu_count)"
        # > ['libssh2']="$(koopa_app_prefix 'libssh2')"
        # > ['lua']="$(koopa_app_prefix 'lua')"
        ['name']='nmap'
        ['openssl']="$(koopa_app_prefix 'openssl3')"
        ['pcre']="$(koopa_app_prefix 'pcre')"
        ['prefix']="${INSTALL_PREFIX:?}"
        ['version']="${INSTALL_VERSION:?}"
        ['zlib']="$(koopa_app_prefix 'zlib')"
    )
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
    ./configure --help
    ./configure "${conf_args[@]}"
    "${app['make']}" --jobs="${dict['jobs']}"
    "${app['make']}" install
    return 0
}
