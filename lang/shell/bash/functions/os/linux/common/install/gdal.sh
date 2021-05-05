#!/usr/bin/env bash

koopa::linux_install_gdal() { # {{{1
    koopa::linux_install_app \
        --name='gdal' \
        --name-fancy='GDAL' \
        "$@"
}

koopa:::linux_install_gdal() { # {{{1
    # """
    # Install GDAL.
    # @note Updated 2021-04-28.
    #
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
    local file jobs make_prefix name prefix url version
    koopa::assert_is_linux
    koopa::activate_opt_prefix geos proj python
    prefix="${INSTALL_PREFIX:?}"
    version="${INSTALL_VERSION:?}"
    name='gdal'
    jobs="$(koopa::cpu_count)"    
    make_prefix="$(koopa::make_prefix)"
    file="${name}-${version}.tar.gz"
    url="https://github.com/OSGeo/${name}/releases/download/v${version}/${file}"
    koopa::download "$url"
    koopa::extract "$file"
    koopa::cd "${name}-${version}"
    koopa::alert_coffee_time
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
    return 0
}
