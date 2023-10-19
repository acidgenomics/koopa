#!/usr/bin/env bash

# FIXME Need to require: liblinear, libssh2.
# FIXME Need to require lua.

main() {
    # """
    # Install nmap.
    # @note Updated 2023-10-19.
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
    local -A dict
    local -a build_deps conf_args deps
    build_deps+=('bison' 'flex')
    deps+=(
        'liblinear'
        'libpcap'
        'libssh2'
        'lua'
        'openssl3'
        'pcre'
        'zlib'
    )
    koopa_activate_app --build-only "${deps[@]}"
    koopa_activate_app "${deps[@]}"
    dict['liblua']="$(koopa_app_prefix 'lua')"
    dict['libpcap']="$(koopa_app_prefix 'libpcap')"
    dict['openssl']="$(koopa_app_prefix 'openssl3')"
    dict['pcre']="$(koopa_app_prefix 'pcre')"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['zlib']="$(koopa_app_prefix 'zlib')"
    conf_args=(
        # Recommended options from Homebrew:
        # > '--disable-universal'
        # > '--without-nmap-update'
        # > '--without-zenmap'
        "--prefix=${dict['prefix']}"
        "--with-liblua=${dict['liblua']}"
        "--with-libpcap=${dict['libpcap']}"
        "--with-libpcre=${dict['pcre']}"
        "--with-libz=${dict['zlib']}"
        "--with-openssl=${dict['openssl']}"
    )
    dict['url']="https://nmap.org/dist/nmap-${dict['version']}.tar.bz2"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    koopa_make_build "${conf_args[@]}"
    return 0
}
