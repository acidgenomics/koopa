#!/usr/bin/env bash

main() { # {{{1
    # """
    # Install GEOS.
    # @note Updated 2022-04-25.
    #
    # Can build with autotools or cmake.
    # See 'INSTALL' file for details.
    # The cmake approach seems to build more reliably inside Docker images.
    #
    # - cmake:
    #   https://trac.osgeo.org/geos/wiki/BuildingOnUnixWithCMake
    # - autotools:
    #   https://trac.osgeo.org/geos/wiki/BuildingOnUnixWithAutotools
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
    local app cmake_args dict
    koopa_assert_has_no_args "$#"
    if koopa_is_linux
    then
        koopa_assert_is_non_existing \
            '/usr/bin/geos-config' \
            '/usr/include/geos' \
            '/usr/include/geos_c.h'
    fi
    koopa_activate_build_opt_prefix 'cmake'
    declare -A app=(
        [cmake]="$(koopa_locate_cmake)"
        [make]="$(koopa_locate_make)"
    )
    declare -A dict=(
        [jobs]="$(koopa_cpu_count)"
        [name]='geos'
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    dict[file]="${dict[version]}.tar.gz"
    dict[url]="https://github.com/lib${dict[name]}/${dict[name]}/\
archive/${dict[file]}"
    koopa_download "${dict[url]}" "${dict[file]}"
    koopa_extract "${dict[file]}"
    koopa_cd "${dict[name]}-${dict[version]}"
    koopa_mkdir 'build'
    koopa_cd 'build'
    cmake_args=(
        '-DBUILD_SHARED_LIBS=ON'
        '-DCMAKE_BUILD_TYPE=Release'
        "-DCMAKE_INSTALL_PREFIX=${dict[prefix]}"
        "-DCMAKE_INSTALL_RPATH=${dict[prefix]}/lib"
        '-DGEOS_ENABLE_TESTS=OFF'
    )
    "${app[cmake]}" .. "${cmake_args[@]}"
    "${app[make]}" --jobs="${dict[jobs]}"
    # > "${app[make]}" test
    "${app[make]}" install
    return 0
}
