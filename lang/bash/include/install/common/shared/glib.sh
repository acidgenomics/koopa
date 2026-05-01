#!/usr/bin/env bash

# NOTE glib 2.79 update errors due to lack of Python packaging:
# ../meson.build:2379:26: ERROR: python is missing modules: packaging

main() {
    # """
    # Install glib.
    # @note Updated 2023-12-22.
    #
    # @seealso
    # - https://developer.gnome.org/glib/
    # - https://formulae.brew.sh/formula/glib
    # - https://www.linuxfromscratch.org/blfs/view/svn/general/glib2.html
    # """
    local -A app dict
    local -a build_deps deps meson_args
    build_deps=('cmake' 'meson' 'ninja' 'pkg-config' 'python')
    deps=('zlib')
    # Linking to our gettext causes build to fail for 2.76.5.
    # > _koopa_is_macos && deps+=('gettext')
    deps+=('libffi' 'pcre2')
    _koopa_activate_app --build-only "${build_deps[@]}"
    _koopa_activate_app "${deps[@]}"
    app['meson']="$(_koopa_locate_meson)"
    app['ninja']="$(_koopa_locate_ninja)"
    _koopa_assert_is_executable "${app[@]}"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['maj_min_ver']="$(_koopa_major_minor_version "${dict['version']}")"
    dict['url']="https://download.gnome.org/sources/glib/\
${dict['maj_min_ver']}/glib-${dict['version']}.tar.xz"
    _koopa_download "${dict['url']}"
    _koopa_extract "$(_koopa_basename "${dict['url']}")" 'src'
    _koopa_cd 'src'
    _koopa_mkdir 'build'
    _koopa_cd 'build'
    _koopa_print_env
    meson_args=(
        "--prefix=${dict['prefix']}"
        '--buildtype=release'
        '-Dlibdir=lib'
    )
    _koopa_dl 'meson args' "${meson_args[*]}"
    "${app['meson']}" "${meson_args[@]}" ..
    "${app['ninja']}" -v
    "${app['ninja']}" install -v
    return 0
}
