#!/usr/bin/env bash

main() {
    # """
    # Install GDAL.
    # @note Updated 2022-06-13.
    #
    # Use 'configure --help' for build options.
    #
    # Use OpenJPEG instead of Jasper.
    # This is particularly important for CentOS builds.
    #
    # @seealso
    # - https://gdal.org/build_hints.html
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/gdal.rb
    # - https://trac.osgeo.org/gdal/wiki/BuildingOnUnix
    # - https://trac.osgeo.org/gdal/wiki/BuildingOnUnixGDAL25dev
    # - https://github.com/OSGeo/gdal/issues/1259
    # - https://github.com/OSGeo/gdal/issues/2402
    # - https://github.com/OSGeo/gdal/issues/1708
    # - https://stackoverflow.com/questions/53511533/
    # """
    local app cmake_args dict
    koopa_assert_has_no_args "$#"
    if koopa_is_linux
    then
        koopa_assert_is_non_existing \
            '/usr/bin/gdal-config' \
            '/usr/include/gdal'
    fi
    koopa_activate_build_opt_prefix 'cmake' 'pkg-config'
    koopa_activate_opt_prefix \
        'geos' \
        'hdf5' \
        'jpeg' \
        'libgeotiff' \
        'libpng' \
        'libtiff' \
        'libtool' \
        'libxml2' \
        'openssl' \
        'pcre2' \
        'proj' \
        'sqlite' \
        'xz' \
        'zstd'
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
    koopa_download "${dict[url]}" "${dict[file]}"
    koopa_extract "${dict[file]}"
    koopa_cd "${dict[name]}-${dict[version]}"
    koopa_mkdir 'build'
    koopa_cd 'build'
    if koopa_is_linux
    then
        dict[shared_ext]='so'
    elif koopa_is_macos
    then
        dict[shared_ext]='dylib'
    fi
    # FIXME Refer to PROJ installer for syntax on specifying shared libraries.
    cmake_args=(
        '-DCMAKE_BUILD_TYPE=Release'
        "-DCMAKE_INSTALL_PREFIX=${dict[prefix]}"
        "-DCMAKE_INSTALL_RPATH=${dict[prefix]}/lib"
        '-DBUILD_APPS=ON'
        '-DBUILD_SHARED_LIBS=ON'
        # cURL support.
        '-DGDAL_USE_CURL=ON'
        "-DCURL_INCLUDE_DIR=${dict[opt_prefix]}/curl/include"
        "-DCURL_LIBRARY=${dict[opt_prefix]}/curl/lib/\
libcurl.${dict[shared_ext]}"
        # GEOS support.
        '-DGDAL_USE_GEOS=ON'
        "-DGEOS_INCLUDE_DIR=${dict[opt_prefix]}/geos/include"
        "-DGEOS_LIBRARY=${dict[opt_prefix]}/geos/lib/\
libgeos.${dict[shared_ext]}"
        # GEOTIFF support (libgeotiff).
        # FIXME Need to reinstall this.
        '-DGDAL_USE_GEOTIFF=ON'
        # FIXME GEOTIFF_INCLUDE_DIR
        # FIXME GEOTIFF_LIBRARY_RELEASE
        # HDF5 support.
        '-DGDAL_USE_HDF5=ON'
        # JPEG support.
        '-DGDAL_USE_JPEG=ON'
        # FIXME JPEG_INCLUDE_DIR (jpeg)
        # FIXME JPEG_LIBRARY_RELEASE
        # OpenSSL support.
        '-DGDAL_USE_OPENSSL=ON'
        # FIXME OPENSSL_ROOT_DIR
        # PCRE2 support.
        '-DGDAL_USE_PCRE2=ON'
        # FIXME PCRE2_INCLUDE_DIR
        # FIXME PCRE2_LIBRARY
        # PNG support (libpng).
        '-DGDAL_USE_PNG=ON'
        # FIXME PNG_PNG_INCLUDE_DIR
        # FIXME PNG_LIBRARY_RELEASE
        # PROJ support.
        # FIXME PROJ_INCLUDE_DIR
        # FIXME PROJ_LIBRARY_RELEASE
        # SQLite3 support (sqlite).
        '-DGDAL_USE_SQLITE3=ON'
        # FIXME SQLite3_INCLUDE_DIR
        # FIXME SQLite3_LIBRARY
        # TIFF support.
        "-DTIFF_INCLUDE_DIR=${dict[opt_prefix]}/libtiff/include"
        "-DTIFF_LIBRARY_RELEASE=${dict[opt_prefix]}/libtiff/lib/\
libtiff.${dict[shared_ext]}"
        # ZSTD support.
        '-DGDAL_USE_ZSTD=ON'
        # FIXME ZSTD_INCLUDE_DIR
        # FIXME ZSTD_LIBRARY
    )
    koopa_mkdir "${dict[prefix]}/include"
    "${app[cmake]}" .. "${cmake_args[@]}"
    "${app[make]}" --jobs="${dict[jobs]}"
    "${app[make]}" install
    return 0
}
