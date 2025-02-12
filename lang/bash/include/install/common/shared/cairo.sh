#!/usr/bin/env bash

main() {
    # """
    # Install Cairo.
    # @note Updated 2023-12-22.
    #
    # @seealso
    # - https://cairographics.org/releases/
    # - https://github.com/conda-forge/cairo-feedstock
    # - https://github.com/Homebrew/homebrew-core/blob/HEAD/Formula/cairo.rb
    # - https://www.linuxfromscratch.org/blfs/view/svn/x/cairo.html
    # """
    local -A app dict
    local -a build_deps deps meson_args
    app['meson']="$(koopa_locate_meson)"
    app['ninja']="$(koopa_locate_ninja)"
    koopa_assert_is_executable "${app[@]}"
    build_deps=('meson' 'ninja' 'pkg-config')
    deps=(
        'zlib'
        'gettext'
        'freetype'
        'icu4c75' # libxml2
        'libxml2'
        'fontconfig'
        'libffi'
        'pcre2'
        'glib'
        'libpng'
        # Inclusion of lzo is causing build failure with 1.18.0.
        # > 'lzo'
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
    dict['jobs']="$(koopa_cpu_count)"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    meson_args+=(
        '--buildtype=release'
        '--default-library=shared'
        "--prefix=${dict['prefix']}"
        '-Dfontconfig=enabled'
        '-Dfreetype=enabled'
        '-Dglib=enabled'
        '-Dlibdir=lib'
        '-Dpng=enabled'
        '-Dxcb=enabled'
        '-Dxlib-xcb=enabled'
        '-Dxlib=enabled'
        '-Dzlib=enabled'
    )
    if koopa_is_macos
    then
        meson_args+=('-Dquartz=disabled')
    fi
    dict['url']="https://cairographics.org/releases/\
cairo-${dict['version']}.tar.xz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    # FIXME Consider making this 'koopa_meson_ninja_build'.
    "${app['meson']}" setup "${meson_args[@]}" 'build'
    "${app['ninja']}" -v -j "${dict['jobs']}" -C 'build'
    "${app['ninja']}" -v -j "${dict['jobs']}" -C 'build' install
    return 0
}
