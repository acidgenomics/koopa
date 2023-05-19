#!/usr/bin/env bash

main() {
    # """
    # Install Cairo.
    # @note Updated 2023-04-10.
    #
    # @seealso
    # - https://cairographics.org/releases/
    # - https://github.com/conda-forge/cairo-feedstock
    # - https://github.com/Homebrew/homebrew-core/blob/HEAD/Formula/cairo.rb
    # """
    local -A dict
    local -a build_deps conf_args deps
    build_deps=('pkg-config')
    deps=(
        'zlib'
        'gettext'
        'freetype'
        'libxml2'
        'fontconfig'
        'libffi'
        'pcre2'
        'glib'
        'libpng'
        'lzo'
        'pixman'
        'xorg-xorgproto'
        'xorg-xcb-proto'
        'xorg-libpthread-stubs'
        'xorg-libxau'
        'xorg-libxdmcp'
        'xorg-libxcb'
        'xorg-libx11'
        'xorg-libxext'
        'xorg-libxrender'
        'expat'
    )
    koopa_activate_app --build-only "${build_deps[@]}"
    koopa_activate_app "${deps[@]}"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    conf_args=(
        '--disable-dependency-tracking'
        '--disable-static'
        '--disable-valgrind'
        '--enable-gobject'
        '--enable-svg'
        '--enable-tee'
        '--enable-xcb'
        '--enable-xlib'
        '--enable-xlib-xcb'
        '--enable-xlib-xrender'
        "--prefix=${dict['prefix']}"
    )
    if koopa_is_macos
    then
        conf_args+=('--enable-quartz-image')
    fi
    dict['url']="https://cairographics.org/releases/\
cairo-${dict['version']}.tar.xz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    koopa_make_build "${conf_args[@]}"
    return 0
}
