#!/usr/bin/env bash

main() {
    # """
    # Install xorg-libxcb.
    # @note Updated 2025-08-21.
    #
    # @seealso
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/libxcb.rb
    # """
    local -A app dict
    local -a conf_args
    _koopa_activate_app --build-only \
        'pkg-config' \
        'python'
    _koopa_activate_app \
        'xorg-xorgproto' \
        'xorg-xcb-proto' \
        'xorg-libpthread-stubs' \
        'xorg-libxau' \
        'xorg-libxdmcp'
    app['python']="$(_koopa_locate_python --realpath)"
    _koopa_assert_is_executable "${app[@]}"
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
# >     dict['url']="https://www.x.org/archive/individual/lib/\
# > libxcb-${dict['version']}.tar.xz"
    dict['url']="https://xorg.freedesktop.org/archive/individual/lib/\
libxcb-${dict['version']}.tar.xz"
    _koopa_download "${dict['url']}"
    _koopa_extract "$(_koopa_basename "${dict['url']}")" 'src'
    _koopa_cd 'src'
    _koopa_make_build "${conf_args[@]}"
    return 0
}
