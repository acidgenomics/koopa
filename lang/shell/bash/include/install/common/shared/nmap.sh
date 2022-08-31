#!/usr/bin/env bash

# NOTE May need to include liblinear here.

# FIXME This is currently failing to build on Ubuntu 22.
# lmathlib.c:(.text+0x663): undefined reference to `cos'
# /usr/bin/ld: /opt/koopa/app/lua/5.4.4/lib/liblua.a(lmathlib.o): in function `math_atan':
# lmathlib.c:(.text+0x6c0): undefined reference to `atan2'
# /usr/bin/ld: /opt/koopa/app/lua/5.4.4/lib/liblua.a(lmathlib.o): in function `math_asin':
# lmathlib.c:(.text+0x6f3): undefined reference to `asin'
# /usr/bin/ld: /opt/koopa/app/lua/5.4.4/lib/liblua.a(lmathlib.o): in function `math_acos':
# lmathlib.c:(.text+0x723): undefined reference to `acos'

main() {
    # """
    # Install nmap.
    # @note Updated 2022-08-27.
    # 
    # @seealso
    # - https://nmap.org/
    # - https://github.com/Homebrew/homebrew-core/blob/HEAD/Formula/nmap.rb
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
        ['jobs']="$(koopa_cpu_count)"
        ['lua']="$(koopa_app_prefix 'lua')"
        ['name']='nmap'
        ['openssl']="$(koopa_app_prefix 'openssl3')"
        ['pcre']="$(koopa_app_prefix 'pcre')"
        ['prefix']="${INSTALL_PREFIX:?}"
        ['version']="${INSTALL_VERSION:?}"
    )
    dict['file']="${dict['name']}-${dict['version']}.tar.bz2"
    dict['url']="https://nmap.org/dist/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd "${dict['name']}-${dict['version']}"
    conf_args=(
        "--prefix=${dict['prefix']}"
        '--disable-universal'
        "--with-liblua=${dict['lua']}"
        "--with-libpcre=${dict['pcre']}"
        "--with-openssl=${dict['openssl']}"
        '--without-nmap-update'
        '--without-zenmap'
    )
    ./configure "${conf_args[@]}"
    "${app['make']}" --jobs="${dict['jobs']}"
    "${app['make']}" install
    return 0
}
