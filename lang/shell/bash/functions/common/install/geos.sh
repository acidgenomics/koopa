#!/usr/bin/env bash

koopa::install_geos() { # {{{1
    koopa::install_app \
        --name='geos' \
        --name-fancy='GEOS' \
        "$@"
}

koopa:::install_geos() { # {{{1
    # """
    # Install GEOS.
    # @note Updated 2021-05-10.
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
    local cmake_args file jobs name prefix url version
    if koopa::is_macos
    then
        koopa::activate_homebrew_opt_prefix cmake
    fi
    prefix="${INSTALL_PREFIX:?}"
    version="${INSTALL_VERSION:?}"
    name='geos'
    jobs="$(koopa::cpu_count)"
    file="${version}.tar.gz"
    url="https://github.com/lib${name}/${name}/archive/${file}"
    koopa::download "$url"
    koopa::extract "$file"
    koopa::mkdir build
    koopa::cd build
    cmake_args=(
        "../${name}-${version}"
        "-DCMAKE_INSTALL_PREFIX=${prefix}"
        # > '-DGEOS_ENABLE_TESTS=OFF'
    )
    cmake "${cmake_args[@]}"
    make --jobs="$jobs"
    # > make test
    make install
    return 0
}
