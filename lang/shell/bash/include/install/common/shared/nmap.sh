#!/usr/bin/env bash

# FIXME This is currently failing to build on Ubuntu 22.
# lmathlib.c:(.text+0x663): undefined reference to `cos'
# /usr/bin/ld: /opt/koopa/app/lua/5.4.4/lib/liblua.a(lmathlib.o): in function `math_atan':
# lmathlib.c:(.text+0x6c0): undefined reference to `atan2'
# /usr/bin/ld: /opt/koopa/app/lua/5.4.4/lib/liblua.a(lmathlib.o): in function `math_asin':
# lmathlib.c:(.text+0x6f3): undefined reference to `asin'
# /usr/bin/ld: /opt/koopa/app/lua/5.4.4/lib/liblua.a(lmathlib.o): in function `math_acos':
# lmathlib.c:(.text+0x723): undefined reference to `acos'

# FIXME Now build is hitting this cryptic error on Ubuntu:
# Nping compiled successfully!
# gmake[2]: Leaving directory '/tmp/koopa-1000-20220831-052903-oexvM4tUgS/nmap-7.92/nping'

# FIXME Yeah looks like we need libpcap.
# When setting '--without-libpcap':
# FPEngine.cc:361:8: error: ‘nsock_pcap_open’ was not declared in this scope

main() {
    # """
    # Install nmap.
    # @note Updated 2022-08-27.
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
    local app conf_args dict
    koopa_activate_build_opt_prefix \
        'bison' \
        'flex'
    koopa_activate_opt_prefix \
        'zlib' \
        'openssl3' \
        'libssh2' \
        'pcre' \
        'lua'
    declare -A app=(
        ['make']="$(koopa_locate_make)"
    )
    [[ -x "${app['make']}" ]] || return 1
    declare -A dict=(
        ['libssh2']="$(koopa_app_prefix 'libssh2')"
        ['lua']="$(koopa_app_prefix 'lua')"
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
        # > '--without-nmap-update'
        "--prefix=${dict['prefix']}"
        "--with-liblua=${dict['lua']}"
        "--with-libpcre=${dict['pcre']}"
        "--with-libssh2=${dict['libssh2']}"
        "--with-libz=${dict['zlib']}"
        "--with-openssl=${dict['openssl']}"
        '--without-liblinear'
        '--without-zenmap'
        # NOTE Setting this causes build to break on Ubuntu.
        # > '--without-libpcap'
    )
    ./configure "${conf_args[@]}"
    "${app['make']}" --jobs=1
    "${app['make']}" install
    return 0
}
