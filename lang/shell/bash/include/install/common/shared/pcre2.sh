#!/usr/bin/env bash

main() {
    # """
    # Install PCRE2.
    # @note Updated 2023-04-10.
    #
    # @seealso
    # - https://www.pcre.org/
    # - https://github.com/Homebrew/homebrew-core/blob/HEAD/Formula/pcre2.rb
    # """
    local -A dict
    local -a conf_args
    koopa_activate_app --build-only \
        'autoconf' \
        'automake' \
        'libtool' \
        'pkg-config'
    koopa_activate_app \
        'zlib' \
        'bzip2'
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    conf_args=(
        '--disable-dependency-tracking'
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
