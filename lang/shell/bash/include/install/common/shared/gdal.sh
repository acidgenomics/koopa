#!/usr/bin/env bash

main() {
    # """
    # Install GDAL.
    # @note Updated 2023-03-24.
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
    koopa_activate_app --build-only \
        'cmake' \
        'libtool' \
        'pkg-config'
    koopa_activate_app \
        'curl' \
        'geos' \
        'hdf5' \
        'libxml2' \
        'openssl3' \
        'pcre2' \
        'sqlite' \
        'zlib' \
        'zstd' \
        'libjpeg-turbo' \
        'libtiff' \
        'proj' \
        'xz' \
        'zstd' \
        'python3.11' \
        'openjdk'
    declare -A app=(
        ['cmake']="$(koopa_locate_cmake)"
        ['make']="$(koopa_locate_make)"
        ['python']="$(koopa_locate_python311 --realpath)"
    )
    [[ -x "${app['cmake']}" ]] || return 1
    [[ -x "${app['make']}" ]] || return 1
    [[ -x "${app['python']}" ]] || return 1
    declare -A dict=(
        ['jobs']="$(koopa_cpu_count)"
        ['make_prefix']="$(koopa_make_prefix)"
        ['name']="${KOOPA_INSTALL_NAME:?}"
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
        ['shared_ext']="$(koopa_shared_ext)"
        ['version']="${KOOPA_INSTALL_VERSION:?}"
    )
    dict['file']="${dict['name']}-${dict['version']}.tar.gz"
    dict['url']="https://github.com/OSGeo/${dict['name']}/releases/download/\
v${dict['version']}/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd "${dict['name']}-${dict['version']}"
    koopa_mkdir 'build'
    koopa_cd 'build'
    dict['curl']="$(koopa_app_prefix 'curl')"
    dict['hdf5']="$(koopa_app_prefix 'hdf5')"
    dict['libtiff']="$(koopa_app_prefix 'libtiff')"
    dict['libxml2']="$(koopa_app_prefix 'libxml2')"
    dict['openjdk']="$(koopa_app_prefix 'openjdk')"
    dict['pcre2']="$(koopa_app_prefix 'pcre2')"
    dict['proj']="$(koopa_app_prefix 'proj')"
    dict['python']="$(koopa_app_prefix 'python3.11')"
    dict['sqlite']="$(koopa_app_prefix 'sqlite')"
    dict['zlib']="$(koopa_app_prefix 'zlib')"
    dict['zstd']="$(koopa_app_prefix 'zstd')"
    cmake_args=(
        # Standard CMake arguments ---------------------------------------------
        '-DCMAKE_BUILD_TYPE=Release'
        "-DCMAKE_CXX_FLAGS=${CPPFLAGS:-}"
        "-DCMAKE_C_FLAGS=${CFLAGS:-}"
        "-DCMAKE_EXE_LINKER_FLAGS=${LDFLAGS:-}"
        "-DCMAKE_INSTALL_PREFIX=${dict['prefix']}"
        "-DCMAKE_INSTALL_RPATH=${dict['prefix']}/lib"
        "-DCMAKE_MODULE_LINKER_FLAGS=${LDFLAGS:-}"
        "-DCMAKE_SHARED_LINKER_FLAGS=${LDFLAGS:-}"
        '-DCMAKE_VERBOSE_MAKEFILE=ON'
        # Build options --------------------------------------------------------
        '-DBUILD_APPS=ON'
        '-DBUILD_JAVA_BINDINGS=ON'
        '-DBUILD_PYTHON_BINDINGS=ON'
        '-DBUILD_SHARED_LIBS=ON'
        '-DGDAL_USE_ARMADILLO=OFF'
        '-DGDAL_USE_ARROW=OFF'
        '-DGDAL_USE_BLOSC=OFF'
        '-DGDAL_USE_BRUNSLI=OFF'
        '-DGDAL_USE_CFITSIO=OFF'
        '-DGDAL_USE_CRNLIB=OFF'
        '-DGDAL_USE_CRYPTOPP=OFF'
        '-DGDAL_USE_CURL=ON'
        '-DGDAL_USE_DEFLATE=OFF'
        '-DGDAL_USE_ECW=OFF'
        '-DGDAL_USE_EXPAT=OFF'
        '-DGDAL_USE_FILEGDB=OFF'
        '-DGDAL_USE_FREEXL=OFF'
        '-DGDAL_USE_FYBA=OFF'
        '-DGDAL_USE_GEOS=ON'
        '-DGDAL_USE_GEOTIFF_INTERNAL=ON'
        '-DGDAL_USE_GIF_INTERNAL=ON'
        '-DGDAL_USE_GTA=OFF'
        '-DGDAL_USE_HDF4=OFF'
        '-DGDAL_USE_HDF5=ON'
        '-DGDAL_USE_HDFS=OFF'
        '-DGDAL_USE_HEIF=OFF'
        '-DGDAL_USE_ICONV=OFF'
        '-DGDAL_USE_IDB=OFF'
        '-DGDAL_USE_JPEG12_INTERNAL=ON'
        '-DGDAL_USE_JPEG_INTERNAL=ON'
        '-DGDAL_USE_JSONC_INTERNAL=ON'
        '-DGDAL_USE_JXL=OFF'
        '-DGDAL_USE_KDU=OFF'
        '-DGDAL_USE_KEA=OFF'
        '-DGDAL_USE_LERC_INTERNAL=ON'
        '-DGDAL_USE_LIBKML=OFF'
        '-DGDAL_USE_LIBLZMA=OFF'
        '-DGDAL_USE_LIBXML2=ON'
        '-DGDAL_USE_LURATECH=OFF'
        '-DGDAL_USE_LZ4=OFF'
        '-DGDAL_USE_MONGOCXX=OFF'
        '-DGDAL_USE_MRSID=OFF'
        '-DGDAL_USE_MSSQL_NCLI=OFF'
        '-DGDAL_USE_MSSQL_ODBC=OFF'
        '-DGDAL_USE_MYSQL=OFF'
        '-DGDAL_USE_NETCDF=OFF'
        '-DGDAL_USE_ODBC=OFF'
        '-DGDAL_USE_ODBCCPP=OFF'
        '-DGDAL_USE_OGDI=OFF'
        '-DGDAL_USE_OPENCAD_INTERNAL=ON'
        '-DGDAL_USE_OPENCL=OFF'
        '-DGDAL_USE_OPENEXR=OFF'
        '-DGDAL_USE_OPENJPEG=OFF'
        '-DGDAL_USE_OPENSSL=ON'
        '-DGDAL_USE_ORACLE=OFF'
        '-DGDAL_USE_PARQUET=OFF'
        '-DGDAL_USE_PCRE2=ON'
        '-DGDAL_USE_PDFIUM=OFF'
        '-DGDAL_USE_PNG_INTERNAL=ON'
        '-DGDAL_USE_POPPLER=OFF'
        '-DGDAL_USE_POSTGRESQL=OFF'
        '-DGDAL_USE_QHULL_INTERNAL=ON'
        '-DGDAL_USE_RASTERLITE2=OFF'
        '-DGDAL_USE_RDB=OFF'
        '-DGDAL_USE_SFCGAL=OFF'
        '-DGDAL_USE_SPATIALITE=OFF'
        '-DGDAL_USE_SQLITE3=ON'
        '-DGDAL_USE_TEIGHA=OFF'
        '-DGDAL_USE_TIFF=ON'
        '-DGDAL_USE_TILEDB=OFF'
        '-DGDAL_USE_WEBP=OFF'
        '-DGDAL_USE_XERCESC=OFF'
        '-DGDAL_USE_ZLIB=ON'
        '-DGDAL_USE_ZSTD=ON'
        # Dependency paths -----------------------------------------------------
        "-DCURL_INCLUDE_DIR=${dict['curl']}/include"
        "-DCURL_LIBRARY=${dict['curl']}/lib/libcurl.${dict['shared_ext']}"
        "-DHDF5_ROOT=${dict['hdf5']}"
        "-DJAVA_HOME=${dict['openjdk']}"
        "-DLIBXML2_INCLUDE_DIR=${dict['libxml2']}/include"
        "-DLIBXML2_LIBRARY=${dict['libxml2']}/lib/libxml2.${dict['shared_ext']}"
        "-DPCRE2_INCLUDE_DIR=${dict['pcre2']}/include"
        "-DPCRE2-8_LIBRARY=${dict['pcre2']}/lib/\
libpcre2-8.${dict['shared_ext']}"
        "-DPROJ_DIR=${dict['proj']}/lib/cmake/proj"
        "-DPROJ_INCLUDE_DIR=${dict['proj']}/include"
        "-DPROJ_LIBRARY=${dict['proj']}/lib/libproj.${dict['shared_ext']}"
        "-DPython_EXECUTABLE=${app['python']}"
        "-DPython_ROOT=${dict['python']}"
        "-DSQLite3_INCLUDE_DIR=${dict['sqlite']}/include"
        "-DSQLite3_LIBRARY=${dict['sqlite']}/lib/\
libsqlite3.${dict['shared_ext']}"
        "-DTIFF_INCLUDE_DIR=${dict['libtiff']}/include"
        "-DTIFF_LIBRARY_RELEASE=${dict['libtiff']}/lib/\
libtiff.${dict['shared_ext']}"
        "-DZLIB_INCLUDE_DIR=${dict['zlib']}/include"
        "-DZLIB_LIBRARY=${dict['zlib']}/lib/libz.${dict['shared_ext']}"
        "-DZSTD_DIR=${dict['zstd']}/lib/cmake/zstd"
    )
    koopa_mkdir "${dict['prefix']}/include"
    koopa_print_env
    koopa_dl 'CMake args' "${cmake_args[*]}"
    "${app['cmake']}" -LH -S .. "${cmake_args[@]}"
    "${app['make']}" VERBOSE=1 --jobs="${dict['jobs']}"
    "${app['make']}" install
    return 0
}
