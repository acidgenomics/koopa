#!/usr/bin/env bash

# """
# Use 'configure --help' for build options.
#
# If you don't need python support you can suppress it at configure using
# '--without-python'.
#
# Use OpenJPEG instead of Jasper.
# This is particularly important for CentOS builds.
# - https://github.com/OSGeo/gdal/issues/2402
# - https://github.com/OSGeo/gdal/issues/1708
# """

koopa::assert_is_linux
[[ "$reinstall" -ne 1 ]] && koopa::assert_is_not_file '/usr/bin/gdal-config'
koopa::assert_is_installed proj python3
koopa::alert_coffee_time
file="${name}-${version}.tar.gz"
url="https://github.com/OSGeo/${name}/releases/download/v${version}/${file}"
koopa::download "$url"
koopa::extract "$file"
koopa::cd "${name}-${version}"
./configure \
    --prefix="$prefix" \
    --with-openjpeg \
    --with-proj="$make_prefix" \
    --with-python='python3' \
    --with-sqlite3="$make_prefix" \
    --without-jasper \
    CFLAGS="-I${make_prefix}/include" \
    CPPFLAGS="-I${make_prefix}/include" \
    LDFLAGS="-L${make_prefix}/lib"
# Use '-d' flag for more verbose debug mode.
make --jobs="$jobs"
make install
