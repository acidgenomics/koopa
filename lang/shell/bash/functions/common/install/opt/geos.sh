#!/usr/bin/env bash

koopa:::install_geos() { # {{{1
    # """
    # Install GEOS.
    # @note Updated 2021-05-26.
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
    # > ./configure --prefix="$prefix"
    # > make --jobs="$jobs"
    # > make check
    # """
    local cmake cmake_args file jobs make name prefix url version
    if koopa::is_macos
    then
        koopa::activate_homebrew_opt_prefix cmake
    fi
    prefix="${INSTALL_PREFIX:?}"
    version="${INSTALL_VERSION:?}"
    jobs="$(koopa::cpu_count)"
    cmake="$(koopa::locate_cmake)"
    make="$(koopa::locate_make)"
    name='geos'
    file="${version}.tar.gz"
    url="https://github.com/lib${name}/${name}/archive/${file}"
    koopa::download "$url" "$file"
    koopa::extract "$file"
    koopa::mkdir build
    koopa::cd build
    cmake_args=(
        "../${name}-${version}"
        "-DCMAKE_INSTALL_PREFIX=${prefix}"
        # > '-DGEOS_ENABLE_TESTS=OFF'
    )
    "$cmake" "${cmake_args[@]}"
    "$make" --jobs="$jobs"
    # > "$make" test
    "$make" install
    return 0
}
