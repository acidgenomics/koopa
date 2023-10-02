#!/usr/bin/env bash

main() {
    # """
    # Install xorg-libxcb.
    # @note Updated 2023-08-31.
    #
    # @seealso
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/libxcb.rb
    # """
    local -A app dict
    local -a conf_args
    koopa_activate_app --build-only \
        'pkg-config' \
        'python3.12'
    koopa_activate_app \
        'xorg-xorgproto' \
        'xorg-xcb-proto' \
        'xorg-libpthread-stubs' \
        'xorg-libxau' \
        'xorg-libxdmcp'
    app['python']="$(koopa_locate_python312 --realpath)"
    koopa_assert_is_executable "${app[@]}"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    conf_args=(
        '--disable-dependency-tracking'
        '--disable-silent-rules'
        '--disable-static'
        '--enable-devel-docs=no'
        '--enable-dri3'
        '--enable-ge'
        '--enable-selinux'
        '--enable-xevie'
        '--enable-xprint'
        "--prefix=${dict['prefix']}"
        '--with-doxygen=no'
        "PYTHON=${app['python']}"
    )
    dict['url']="https://www.x.org/archive/individual/lib/\
libxcb-${dict['version']}.tar.xz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    koopa_make_build "${conf_args[@]}"
    return 0
}
