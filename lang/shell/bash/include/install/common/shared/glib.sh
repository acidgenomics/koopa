#!/usr/bin/env bash

main() {
    # """
    # Install glib.
    # @note Updated 2022-10-06.
    #
    # @seealso
    # - https://developer.gnome.org/glib/
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/glib.rb
    # - https://www.linuxfromscratch.org/blfs/view/svn/general/glib2.html
    # """
    local app build_deps deps meson_args dict
    build_deps=('cmake' 'meson' 'ninja' 'pkg-config' 'python')
    deps=('zlib')
    koopa_is_macos && deps+=('gettext')
    deps+=('libffi' 'pcre2')
    koopa_activate_app --build-only "${build_deps[@]}"
    koopa_activate_app "${deps[@]}"
    declare -A app=(
        ['meson']="$(koopa_locate_meson)"
        ['ninja']="$(koopa_locate_ninja)"
    )
    [[ -x "${app['meson']}" ]] || return 1
    [[ -x "${app['ninja']}" ]] || return 1
    declare -A dict=(
        ['name']='glib'
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
        ['version']="${KOOPA_INSTALL_VERSION:?}"
    )
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
    )
    "${app['meson']}" "${meson_args[@]}" ..
    "${app['ninja']}" -v
    "${app['ninja']}" install -v
    return 0
}
