#!/usr/bin/env bash

koopa:::install_gdal() { # {{{1
    # """
    # Install GDAL.
    # @note Updated 2021-11-24.
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
    local app brew_opt_pkgs conf_args dict opt_pkgs
    declare -A app=(
        [make]="$(koopa::locate_make)"
    )
    declare -A dict=(
        [jobs]="$(koopa::cpu_count)"
        [make_prefix]="$(koopa::make_prefix)"
        [name]='gdal'
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    conf_args=(
        "--prefix=${dict[prefix]}"
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
        conf_args+=(
            "CFLAGS=-I${dict[make_prefix]}/include"
            "CPPFLAGS=-I${dict[make_prefix]}/include"
            "LDFLAGS=-L${dict[make_prefix]}/lib"
        )
    elif koopa::is_macos
    then
        brew_opt_pkgs=('sqlite')
        koopa::activate_homebrew_opt_prefix "${brew_opt_pkgs[@]}"
    fi
    koopa::activate_opt_prefix "${opt_pkgs[@]}"
    dict[file]="${dict[name]}-${dict[version]}.tar.gz"
    dict[url]="https://github.com/OSGeo/${dict[name]}/releases/download/\
v${dict[version]}/${dict[file]}"
    koopa::download "${dict[url]}" "${dict[file]}"
    koopa::extract "${dict[file]}"
    koopa::cd "${dict[name]}-${dict[version]}"
    koopa::alert_coffee_time
    ./configure "${conf_args[@]}"
    # Use '-d' flag for more verbose debug mode.
    "${app[make]}" --jobs="${dict[jobs]}"
    "${app[make]}" install
    return 0
}
