#!/usr/bin/env bash

main() {
    # """
    # Install PCRE2.
    # @note Updated 2024-11-26.
    #
    # @seealso
    # - https://www.pcre.org/
    # - https://github.com/Homebrew/homebrew-core/blob/HEAD/Formula/pcre2.rb
    # """
    local -A dict
    local -a build_deps conf_args deps
    build_deps=(
        'autoconf'
        'automake'
        'libtool'
        'pkg-config'
    )
    deps=('zlib')
    if ! koopa_is_macos
    then
        deps+=('bzip2')
    fi
    koopa_activate_app --build-only "${build_deps[@]}"
    koopa_activate_app "${deps[@]}"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    conf_args=(
        '--disable-dependency-tracking'
        '--disable-static'
        '--enable-jit'
        '--enable-pcre2-16'
        '--enable-pcre2-32'
        '--enable-pcre2grep-libbz2'
        '--enable-pcre2grep-libz'
        "--prefix=${dict['prefix']}"
    )
    dict['url']="https://github.com/PhilipHazel/pcre2/releases/download/\
pcre2-${dict['version']}/pcre2-${dict['version']}.tar.bz2"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    koopa_make_build "${conf_args[@]}"
    return 0
}
