#!/usr/bin/env bash

main() { # {{{1
    # """
    # Install HarfBuzz.
    # @note Updated 2022-04-07.
    #
    # @seealso
    # - https://harfbuzz.github.io/building.html
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/
    #     harfbuzz.rb
    # - https://www.linuxfromscratch.org/blfs/view/svn/general/harfbuzz.html
    # - https://github.com/harfbuzz/harfbuzz/blob/main/.circleci/config.yml
    # """
    local app dict
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [meson]="$(koopa_locate_meson)"
        [ninja]="$(koopa_locate_ninja)"
    )
    declare -A dict=(
        [jobs]="$(koopa_cpu_count)"
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
    # depends_on "cairo"
    # depends_on "freetype"
    # depends_on "glib"
    # depends_on "gobject-introspection"
    # depends_on "graphite2"
    koopa_activate_opt_prefix \
        'icu4c' \
        'meson' \
        'ninja'
    meson_args=(
        # > '--default-library=both'
        # > '-Dcairo=enabled'
        # > '-Dcoretext=enabled'
        # > '-Dfreetype=enabled'
        # > '-Dglib=enabled'
        # > '-Dgobject=enabled'
        # > '-Dgraphite=enabled'
        # > '-Dintrospection=enabled'
        "--prefix=${dict[prefix]}"
        '--buildtype=release'
        '-Dicu=enabled'
    )
    "${app[meson]}" "${meson_args[@]}" build
    # Alternate build approach using meson.
    # > "${app[meson]}" compile -C build
    # > "${app[meson]}" test -C build
    # Using ninja instead, as it's faster.
    "${app[ninja]}" -j "${dict[jobs]}" -C 'build'
    # > "${app[ninja]}" test
    "${app[ninja]}" -C 'build' install
    return 0
}
