#!/usr/bin/env bash

main() {
    # """
    # Install pixman.
    # @note Updated 2024-12-30.
    #
    # @seealso
    # - https://github.com/macports/macports-ports/blob/master/graphics/
    #     libpixman/Portfile
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/pixman.rb
    # """
    local -A app dict
    local -a build_deps meson_args
    build_deps=(
        'meson'
        'ninja'
        'pkg-config'
    )
    koopa_activate_app --build-only "${build_deps[@]}"
    app['meson']="$(koopa_locate_meson)"
    app['ninja']="$(koopa_locate_ninja)"
    koopa_assert_is_executable "${app[@]}"
    dict['jobs']="$(koopa_cpu_count)"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['url']="https://cairographics.org/releases/\
pixman-${dict['version']}.tar.gz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    meson_args+=(
        '--buildtype=release'
        '--default-library=shared'
        '--libdir=lib'
        "--prefix=${dict['prefix']}"
    )
    # FIXME Rework this to use koopa_meson_ninja_build.
    # Refer to harfbuzz installer for shared code.
    # https://mesonbuild.com/Builtin-options.html
    "${app['meson']}" setup "${meson_args[@]}" 'build'
    "${app['ninja']}" -v -j "${dict['jobs']}" -C 'build'
    "${app['ninja']}" -v -j "${dict['jobs']}" -C 'build' install
    koopa_assert_is_dir "${dict['prefix']}/lib/pkgconfig"
    return 0
}
