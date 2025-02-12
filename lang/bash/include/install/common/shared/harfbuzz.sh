#!/usr/bin/env bash

# NOTE Consider adding support for:
# - cairo
# - gobject-introspection
# - graphite2

main() {
    # """
    # Install HarfBuzz.
    # @note Updated 2023-06-01.
    #
    # @seealso
    # - https://harfbuzz.github.io/building.html
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/
    #     harfbuzz.rb
    # - https://www.linuxfromscratch.org/blfs/view/svn/general/harfbuzz.html
    # - https://github.com/harfbuzz/harfbuzz/blob/main/.circleci/config.yml
    # """
    local -A app dict
    local -a build_deps deps
    build_deps=(
        'cmake'
        'meson'
        'ninja'
        'pkg-config'
    )
    deps=(
        'zlib'
        'gettext'
        'libffi'
        'pcre2'
        'glib'
        'freetype'
        'icu4c75'
    )
    koopa_activate_app --build-only "${build_deps[@]}"
    koopa_activate_app "${deps[@]}"
    app['meson']="$(koopa_locate_meson)"
    app['ninja']="$(koopa_locate_ninja)"
    koopa_assert_is_executable "${app[@]}"
    dict['jobs']="$(koopa_cpu_count)"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['url']="https://github.com/harfbuzz/harfbuzz/archive/\
${dict['version']}.tar.gz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    meson_args+=(
        '--buildtype=release'
        '--default-library=shared'
        "--prefix=${dict['prefix']}"
        '-Dcairo=disabled'
        '-Dcoretext=enabled'
        '-Dfreetype=enabled'
        '-Dglib=enabled'
        '-Dgobject=disabled'
        '-Dgraphite=disabled'
        '-Dicu=enabled'
        '-Dintrospection=disabled'
        '-Dlibdir=lib'
    )
    # FIXME Consider making this 'koopa_meson_ninja_build'.
    "${app['meson']}" setup "${meson_args[@]}" 'build'
    "${app['ninja']}" -v -j "${dict['jobs']}" -C 'build'
    "${app['ninja']}" -v -j "${dict['jobs']}" -C 'build' install
    return 0
}
