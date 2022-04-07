#!/usr/bin/env bash

install_geos() { # {{{1
    # """
    # Install GEOS.
    # @note Updated 2022-04-06.
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
    #
    # @seealso
    # - https://github.com/libgeos/geos/blob/main/INSTALL.md
    # """
    local app dict
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [brew]="$(koopa_locate_brew --allow-missing)"
        [cmake]="$(koopa_locate_cmake)"
        [make]="$(koopa_locate_make)"
    )
    declare -A dict=(
        [jobs]="$(koopa_cpu_count)"
        [name]='geos'
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    if koopa_is_installed "${app[brew]}"
    then
        koopa_activate_homebrew_opt_prefix 'cmake'
    fi
    dict[file]="${dict[version]}.tar.gz"
    dict[url]="https://github.com/lib${dict[name]}/${dict[name]}/\
archive/${dict[file]}"
    koopa_download "${dict[url]}" "${dict[file]}"
    koopa_extract "${dict[file]}"
    koopa_mkdir 'build'
    koopa_cd 'build'
    # Can disable tests with:
    # > '-DGEOS_ENABLE_TESTS='OFF'
    "${app[cmake]}" \
        ../"${dict[name]}-${dict[version]}" \
        -DCMAKE_BUILD_TYPE='Release' \
        -DCMAKE_INSTALL_PREFIX="${dict[prefix]}"
    "${app[make]}" --jobs="${dict[jobs]}"
    # > "${app[make]}" test
    "${app[make]}" install
    return 0
}
