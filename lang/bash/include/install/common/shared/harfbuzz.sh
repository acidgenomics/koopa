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
        'icu4c'
    )
    _koopa_activate_app --build-only "${build_deps[@]}"
    _koopa_activate_app "${deps[@]}"
    app['meson']="$(_koopa_locate_meson)"
    app['ninja']="$(_koopa_locate_ninja)"
    _koopa_assert_is_executable "${app[@]}"
    dict['jobs']="$(_koopa_cpu_count)"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['url']="https://github.com/harfbuzz/harfbuzz/archive/\
${dict['version']}.tar.gz"
    _koopa_download "${dict['url']}"
    _koopa_extract "$(_koopa_basename "${dict['url']}")" 'src'
    _koopa_cd 'src'
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
    # FIXME Consider making this '_koopa_meson_ninja_build'.
    "${app['meson']}" setup "${meson_args[@]}" 'build'
    "${app['ninja']}" -v -j "${dict['jobs']}" -C 'build'
    "${app['ninja']}" -v -j "${dict['jobs']}" -C 'build' install
    return 0
}
