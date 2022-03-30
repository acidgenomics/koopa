#!/usr/bin/env bash

install_harfbuzz() { # {{{1
    # """
    # Install HarfBuzz.
    # @note Updated 2022-03-30.
    #
    # @seealso
    # - https://harfbuzz.github.io/building.html
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/
    #     harfbuzz.rb
    # - https://www.linuxfromscratch.org/blfs/view/svn/general/harfbuzz.html
    # """
    local app dict
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [meson]="$(koopa_locate_meson)"
        [ninja]="$(koopa_locate_ninja)"
    )
    declare -A dict=(
        [name]='harfbuzz'
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    dict[file]="${dict[version]}.tar.gz"
    dict[url]="https://github.com/${dict[name]}/${dict[name]}/\
archive/${dict[file]}"
    koopa_download "${dict[url]}" "${dict[file]}"
    koopa_extract "${dict[file]}"
    koopa_cd "${dict[name]}-${dict[version]}"
    # depends_on "meson" => :build
    # depends_on "ninja" => :build
    # depends_on "cairo"
    # depends_on "freetype"
    # depends_on "glib"
    # depends_on "gobject-introspection"
    # depends_on "graphite2"
    koopa_activate_opt_prefix 'icu4c'
    meson_args=(
        '--buildtype=release'
        '--default-library=both'
        "--prefix=${dict[prefix]}"
        '-Dcairo=enabled'
        '-Dcoretext=enabled'
        '-Dfreetype=enabled'
        '-Dglib=enabled'
        '-Dgobject=enabled'
        '-Dgraphite=enabled'
        '-Dicu=enabled'
        '-Dintrospection=enabled'
    )
    "${app[meson]}" "${meson_args[@]}" build
    # > "${app[meson]}" test -Cbuild
    # > meson compile -C build
    "${app[ninja]}"
    # > "${app[ninja]}" test
    "${app[ninja]}" install
    return 0
}
