#!/usr/bin/env bash

main() {
    # """
    # Install PCRE.
    # @note Updated 2025-01-03.
    #
    # @seealso
    # - https://www.pcre.org/
    # - https://github.com/Homebrew/homebrew-core/blob/HEAD/Formula/pcre.rb
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
        '--disable-static'
        '--enable-pcre16'
        '--enable-pcre32'
        '--enable-pcre8'
        '--enable-pcregrep-libbz2'
        '--enable-pcregrep-libz'
        '--enable-unicode-properties'
        '--enable-utf8'
        "--prefix=${dict['prefix']}"
    )
    dict['url']="https://koopa.acidgenomics.com/src/pcre/\
${dict['version']}.tar.bz2"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    koopa_make_build "${conf_args[@]}"
    return 0
}
