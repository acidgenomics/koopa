#!/usr/bin/env bash

main() {
    # """
    # Install glib.
    # @note Updated 2023-04-05.
    #
    # @seealso
    # - https://developer.gnome.org/glib/
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/glib.rb
    # - https://www.linuxfromscratch.org/blfs/view/svn/general/glib2.html
    # """
    local -A app dict
    local -a build_deps deps meson_args
    build_deps=('cmake' 'meson' 'ninja' 'pkg-config' 'python3.11')
    deps=('zlib')
    koopa_is_macos && deps+=('gettext')
    deps+=('libffi' 'pcre2')
    koopa_activate_app --build-only "${build_deps[@]}"
    koopa_activate_app "${deps[@]}"
    app['meson']="$(koopa_locate_meson)"
    app['ninja']="$(koopa_locate_ninja)"
    koopa_assert_is_executable "${app[@]}"
    dict['name']='glib'
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['maj_min_ver']="$(koopa_major_minor_version "${dict['version']}")"
    dict['file']="${dict['name']}-${dict['version']}.tar.xz"
    dict['url']="https://download.gnome.org/sources/${dict['name']}/\
${dict['maj_min_ver']}/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd "${dict['name']}-${dict['version']}"
    koopa_mkdir 'build'
    koopa_cd 'build'
    koopa_print_env
    meson_args=(
        "--prefix=${dict['prefix']}"
        '--buildtype=release'
        # Avoid 'lib64' inconsistency on Linux.
        '-Dlibdir=lib'
    )
    koopa_dl 'meson args' "${meson_args[*]}"
    "${app['meson']}" "${meson_args[@]}" ..
    "${app['ninja']}" -v
    "${app['ninja']}" install -v
    return 0
}
