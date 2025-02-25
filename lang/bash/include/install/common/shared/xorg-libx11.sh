#!/usr/bin/env bash

# NOTE Consider adding support for 'xorg-macros'.

main() {
    # """
    # Install xorg-libx11.
    # @note Updated 2025-02-20.
    #
    # @seealso
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/libxcb.rb
    # - https://github.com/Homebrew/homebrew-core/pull/133898
    # """
    local -A dict
    local -a conf_args
    koopa_activate_app --build-only \
        'pkg-config' \
        'sed'
    koopa_activate_app \
        'xorg-xorgproto' \
        'xorg-xtrans' \
        'xorg-libpthread-stubs' \
        'xorg-libxau' \
        'xorg-libxdmcp' \
        'xorg-libxcb'
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    conf_args+=(
        '--disable-silent-rules'
        '--disable-static'
        '--enable-ipv6'
        '--enable-loadable-i18n'
        '--enable-specs=no'
        '--enable-tcp-transport'
        '--enable-unix-transport'
        '--enable-xthreads'
        "--prefix=${dict['prefix']}"
    )
# >     dict['url']="https://www.x.org/archive/individual/lib/\
# > libX11-${dict['version']}.tar.xz"
    dict['url']="https://xorg.freedesktop.org/archive/individual/lib/\
libX11-${dict['version']}.tar.xz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    koopa_make_build "${conf_args[@]}"
    return 0
}
