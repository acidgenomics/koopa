#!/usr/bin/env bash

# FIXME This is failing to detect lzo header correctly:
# ../util/cairo-script/cairo-script-file.c
# ../util/cairo-script/cairo-script-file.c:45:10: fatal error: 'lzo/lzo2a.h' file not found
# #include <lzo/lzo2a.h>

main() {
    # """
    # Install Cairo.
    # @note Updated 2023-12-22.
    #
    # @seealso
    # - https://cairographics.org/releases/
    # - https://github.com/conda-forge/cairo-feedstock
    # - https://github.com/Homebrew/homebrew-core/blob/HEAD/Formula/cairo.rb
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
        'icu4c'
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
        '-Dglib=enabled'
        '-Dpng=enabled'
        '-Dxcb=enabled'
        '-Dxlib=enabled'
        '-Dzlib=enabled'
    )
    if koopa_is_macos
    then
        conf_args+=('-Dquartz=enabled')
    fi
    dict['url']="https://cairographics.org/releases/\
cairo-${dict['version']}.tar.xz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    "${app['meson']}" setup "${meson_args[@]}" 'build'
    "${app['ninja']}" -j "${dict['jobs']}" -C 'build'
    "${app['ninja']}" -C 'build' install
    # Alternate meson approach:
    # > "${app['meson']}" compile -C 'build'
    # > "${app['meson']}" test -C 'build'
    # > "${app['meson']}" install -C 'build'
    return 0
}
