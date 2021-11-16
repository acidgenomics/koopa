#!/usr/bin/env bash

koopa:::install_gdal() { # {{{1
    # """
    # Install GDAL.
    # @note Updated 2021-05-26.
    #
    # Use 'configure --help' for build options.
    #
    # Use OpenJPEG instead of Jasper.
    # This is particularly important for CentOS builds.
    #
    # @seealso
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/gdal.rb
    # - https://trac.osgeo.org/gdal/wiki/BuildingOnUnixGDAL25dev
    # - https://github.com/OSGeo/gdal/issues/1259
    # - https://github.com/OSGeo/gdal/issues/2402
    # - https://github.com/OSGeo/gdal/issues/1708
    # """
    local brew_opt_pkgs conf_args file jobs make make_prefix name opt_pkgs
    local prefix url version
    prefix="${INSTALL_PREFIX:?}"
    version="${INSTALL_VERSION:?}"
    make="$(koopa::locate_make)"
    name='gdal'
    conf_args=(
        "--prefix=${prefix}"
        '--with-armadillo=no'
        '--with-openjpeg'
        '--with-qhull=no'
        '--without-ecw'
        '--without-exr'
        '--without-fgdb'
        '--without-fme'
        '--without-grass'
        '--without-gta'
        '--without-hdf4'
        '--without-idb'
        '--without-ingres'
        '--without-jasper'
        '--without-jp2mrsid'
        '--without-jpeg12'
        '--without-kakadu'
        '--without-libgrass'
        '--without-mrsid'
        '--without-mrsid_lidar'
        '--without-msg'
        '--without-mysql'
        '--without-oci'
        '--without-ogdi'
        '--without-perl'
        '--without-podofo'
        '--without-python'
        '--without-rasdaman'
        '--without-sde'
        '--without-sosi'
    )
    opt_pkgs=('geos' 'proj')
    if koopa::is_linux
    then
        opt_pkgs+=('sqlite')
        make_prefix="$(koopa::make_prefix)"
        conf_args+=(
            "CFLAGS=-I${make_prefix}/include"
            "CPPFLAGS=-I${make_prefix}/include"
            "LDFLAGS=-L${make_prefix}/lib"
        )
    elif koopa::is_macos
    then
        brew_opt_pkgs=('sqlite')
        koopa::activate_homebrew_opt_prefix "${brew_opt_pkgs[@]}"
    fi
    koopa::activate_opt_prefix "${opt_pkgs[@]}"
    jobs="$(koopa::cpu_count)"
    file="${name}-${version}.tar.gz"
    url="https://github.com/OSGeo/${name}/releases/download/v${version}/${file}"
    koopa::download "$url" "$file"
    koopa::extract "$file"
    koopa::cd "${name}-${version}"
    koopa::alert_coffee_time
    ./configure "${conf_args[@]}"
    # Use '-d' flag for more verbose debug mode.
    "$make" --jobs="$jobs"
    "$make" install
    return 0
}
