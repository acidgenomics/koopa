#!/usr/bin/env bash

# FIXME Now hitting this Meson build error on macOS:
# > Checking if "GCC size_t typedef is long long" compiles: NO

main() {
    # """
    # Install glib.
    # @note Updated 2022-08-10.
    #
    # @seealso
    # - https://developer.gnome.org/glib/
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/glib.rb
    # - https://www.linuxfromscratch.org/blfs/view/svn/general/glib2.html
    # """
    local app meson_args dict
    koopa_activate_build_opt_prefix \
        'pkg-config' \
        'python' \
        'meson' \
        'ninja'
    koopa_activate_opt_prefix \
        'zlib' \
        'gettext' \
        'libffi' \
        'pcre'
    declare -A app=(
        [meson]="$(koopa_locate_meson)"
        [ninja]="$(koopa_locate_ninja)"
    )
    [[ -x "${app[meson]}" ]] || return 1
    [[ -x "${app[ninja]}" ]] || return 1
    declare -A dict=(
        [name]='glib'
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    dict[maj_min_ver]="$(koopa_major_minor_version "${dict[version]}")"
    dict[file]="${dict[name]}-${dict[version]}.tar.xz"
    dict[url]="https://download.gnome.org/sources/${dict[name]}/\
${dict[maj_min_ver]}/${dict[file]}"
    koopa_download "${dict[url]}" "${dict[file]}"
    koopa_extract "${dict[file]}"
    koopa_cd "${dict[name]}-${dict[version]}"
    koopa_mkdir 'build'
    koopa_cd 'build'
    meson_args=(
        "--prefix=${dict[prefix]}"
        '--buildtype=release'
        # > '-Dgtk_doc=true'
        # > '-Dman=true'
    )
    "${app[meson]}" "${meson_args[@]}" ..
    "${app[ninja]}" -v
    "${app[ninja]}" install -v
    return 0
}
