#!/usr/bin/env bash

install_geos() { # {{{1
    # """
    # Install GEOS.
    # @note Updated 2021-04-28.
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
    local file jobs name prefix url version
    koopa::assert_is_linux
    prefix="${INSTALL_PREFIX:?}"
    version="${INSTALL_VERSION:?}"
    name='geos'
    jobs="$(koopa::cpu_count)"
    file="${version}.tar.gz"
    url="https://github.com/libgeos/${name}/archive/${file}"
    koopa::download "$url"
    koopa::extract "$file"
    koopa::mkdir build
    koopa::cd build
    cmake "../${name}-${version}" \
        -DCMAKE_INSTALL_PREFIX="$prefix"
        # -DGEOS_ENABLE_TESTS=OFF
    make --jobs="$jobs"
    # > make test
    make install
    return 0
}

install_geos "$@"
