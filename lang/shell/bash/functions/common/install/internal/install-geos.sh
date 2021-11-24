#!/usr/bin/env bash

koopa:::install_geos() { # {{{1
    # """
    # Install GEOS.
    # @note Updated 2021-11-24.
    #
    # Can build with autotools or cmake.
    # See 'INSTALL' file for details.
    # The cmake approach seems to build more reliably inside Docker images.
    #
    # - autotools:
    #   https://trac.osgeo.org/geos/wiki/BuildingOnUnixWithAutotools
    # - cmake:
    #   https://trac.osgeo.org/geos/wiki/BuildingOnUnixWithCMake
    #
    # Alternate autotools approach:
    # > ./autogen.sh
    # > ./configure --prefix="${dict[prefix]}"
    # > "${app[make]}" --jobs="${dict[jobs]}"
    # > "${app[make]}" check
    # """
    local app dict
    declare -A app=(
        [cmake]="$(koopa::locate_cmake)"
        [make]="$(koopa::locate_make)"
    )
    declare -A dict=(
        [jobs]="$(koopa::cpu_count)"
        [name]='geos'
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    if koopa::is_macos
    then
        koopa::activate_homebrew_opt_prefix 'cmake'
    fi
    dict[file]="${dict[version]}.tar.gz"
    dict[url]="https://github.com/lib${dict[name]}/${dict[name]}/\
archive/${dict[file]}"
    koopa::download "${dict[url]}" "${dict[file]}"
    koopa::extract "${dict[file]}"
    koopa::mkdir 'build'
    koopa::cd 'build'
    # Can disable tests with:
    # > '-DGEOS_ENABLE_TESTS='OFF'
    "${app[cmake]}" \
        ../"${dict[name]}-${dict[version]}" \
        -DCMAKE_INSTALL_PREFIX="${dict[prefix]}"
    "${app[make]}" --jobs="${dict[jobs]}"
    # > "${app[make]}" test
    "${app[make]}" install
    return 0
}
