#!/usr/bin/env bash

main() {
    # """
    # Install libpng.
    # @note Updated 2023-04-10.
    #
    # @seealso
    # - http://www.libpng.org/pub/png/libpng.html
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/libpng.rb
    # """
    local -A dict
    local -a conf_args
    koopa_activate_app 'pkg-config'
    koopa_activate_app 'zlib'
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    # Convert '1.6.37' to '16'.
    dict['maj_min_ver']="$(koopa_major_minor_version "${dict['version']}")"
    dict['version2']="$( \
        koopa_gsub \
            --fixed \
            --pattern='.' \
            --replacement='' \
            "${dict['maj_min_ver']}" \
    )"
    conf_args=(
        '--disable-dependency-tracking'
        '--disable-silent-rules'
        '--disable-static'
        '--enable-shared=yes'
        "--prefix=${dict['prefix']}"
    )
    dict['url']="https://downloads.sourceforge.net/project/libpng/\
libpng${dict['version2']}/${dict['version']}/libpng-${dict['version']}.tar.xz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    koopa_make_build "${conf_args[@]}"
    return 0
}
