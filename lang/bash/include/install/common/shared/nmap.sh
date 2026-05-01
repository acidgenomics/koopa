#!/usr/bin/env bash

main() {
    # """
    # Install nmap.
    # @note Updated 2024-12-30.
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
    # - Regarding Lua dependency issue on Linux:
    #   https://seclists.org/nmap-dev/2016/q1/268
    # """
    local -A dict
    local -a build_deps conf_args deps
    build_deps+=('bison' 'flex')
    deps+=(
        'liblinear'
        'libpcap'
        'libssh2'
        'openssl'
        'pcre2'
        'zlib'
    )
    _koopa_is_macos && deps+=('lua')
    _koopa_activate_app --build-only "${deps[@]}"
    _koopa_activate_app "${deps[@]}"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['libpcap']="$(_koopa_app_prefix 'libpcap')"
    dict['openssl']="$(_koopa_app_prefix 'openssl')"
    dict['pcre2']="$(_koopa_app_prefix 'pcre2')"
    dict['zlib']="$(_koopa_app_prefix 'zlib')"
    conf_args+=(
        '--disable-universal'
        "--prefix=${dict['prefix']}"
        "--with-libpcap=${dict['libpcap']}"
        "--with-libpcre=${dict['pcre2']}"
        "--with-libz=${dict['zlib']}"
        "--with-openssl=${dict['openssl']}"
        '--without-nmap-update'
        '--without-zenmap'
    )
    if _koopa_is_macos
    then
        dict['liblua']="$(_koopa_app_prefix 'lua')"
        conf_args+=("--with-liblua=${dict['liblua']}")
    else
        conf_args+=('--with-liblua=included')
    fi
    dict['url']="https://nmap.org/dist/nmap-${dict['version']}.tar.bz2"
    _koopa_download "${dict['url']}"
    _koopa_extract "$(_koopa_basename "${dict['url']}")" 'src'
    _koopa_cd 'src'
    _koopa_make_build "${conf_args[@]}"
    return 0
}
