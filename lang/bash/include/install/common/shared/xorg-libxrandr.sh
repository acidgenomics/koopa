#!/usr/bin/env bash

main() {
    # """
    # Install libxrandr.
    # @note Updated 2025-02-20.
    #
    # @seealso
    # - https://github.com/Homebrew/homebrew-core/blob/master/
    #     Formula/libxrandr.rb
    # """
    local -A dict
    local -a conf_args
    koopa_activate_app --build-only 'pkg-config'
    koopa_activate_app \
        'xorg-xorgproto' \
        'xorg-libpthread-stubs' \
        'xorg-libxau' \
        'xorg-libxdmcp' \
        'xorg-libxcb' \
        'xorg-libx11' \
        'xorg-libxext' \
        'xorg-libxrender'
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    conf_args=(
        '--disable-dependency-tracking'
        '--disable-silent-rules'
        '--disable-static'
        "--prefix=${dict['prefix']}"
    )
# >     dict['url']="https://www.x.org/archive/individual/lib/\
# > libXrandr-${dict['version']}.tar.xz"
    dict['url']="https://xorg.freedesktop.org/archive/individual/lib/\
libXrandr-${dict['version']}.tar.xz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    koopa_make_build "${conf_args[@]}"
    return 0
}
