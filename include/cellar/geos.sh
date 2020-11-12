#!/usr/bin/env bash
# shellcheck disable=SC2154

# """
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

koopa::assert_is_not_file /usr/bin/geos-config
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
