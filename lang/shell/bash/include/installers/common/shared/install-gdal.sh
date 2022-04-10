#!/usr/bin/env bash

main() { # {{{1
    # """
    # Install GDAL.
    # @note Updated 2022-04-08.
    #
    # Use 'configure --help' for build options.
    #
    # Use OpenJPEG instead of Jasper.
    # This is particularly important for CentOS builds.
    #
    # @seealso
    # - https://gdal.org/build_hints.html
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/gdal.rb
    # - https://trac.osgeo.org/gdal/wiki/BuildingOnUnixGDAL25dev
    # - https://github.com/OSGeo/gdal/issues/1259
    # - https://github.com/OSGeo/gdal/issues/2402
    # - https://github.com/OSGeo/gdal/issues/1708
    # """
    local app dict
    koopa_assert_has_no_args "$#"
    koopa_activate_opt_prefix 'cmake' 'geos' 'pkg-config' 'proj' 'sqlite'
    declare -A app=(
        [cmake]="$(koopa_locate_cmake)"
        [make]="$(koopa_locate_make)"
    )
    declare -A dict=(
        [jobs]="$(koopa_cpu_count)"
        [make_prefix]="$(koopa_make_prefix)"
        [name]='gdal'
        [opt_prefix]="$(koopa_opt_prefix)"
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    dict[file]="${dict[name]}-${dict[version]}.tar.gz"
    dict[url]="https://github.com/OSGeo/${dict[name]}/releases/download/\
v${dict[version]}/${dict[file]}"
    koopa_alert_coffee_time
    koopa_download "${dict[url]}" "${dict[file]}"
    koopa_extract "${dict[file]}"
    koopa_cd "${dict[name]}-${dict[version]}"
    conf_args=(
        "--prefix=${dict[prefix]}"
        '--with-armadillo=no'
        '--with-openjpeg'
        "--with-proj=${dict[opt_prefix]}/proj"
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
        '--without-sosi'
    )
    if [[ "${INSTALL_LINK_IN_MAKE:?}" -eq 0 ]]
    then
        conf_args+=(
            '--disable-shared'
            '--enable-static'
            '--without-ld-shared'
        )
    fi
    ./configure "${conf_args[@]}"
    # Use '-d' flag for more verbose debug mode.
    "${app[make]}" --jobs="${dict[jobs]}"
    "${app[make]}" install
    return 0
}
