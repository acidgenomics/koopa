#!/usr/bin/env bash

# NOTE Regarding Python bindings:
# Could NOT find Python (missing: Python_NumPy_INCLUDE_DIRS NumPy)
#
# NOTE May be able to enable these:
# * ICONV component has been detected, but is disabled with GDAL_USE_ICONV=OFF
# * EXPAT component has been detected, but is disabled with GDAL_USE_EXPAT=OFF
# * OPENCL component has been detected, but is disabled with GDAL_USE_OPENCL=OFF

# FIXME Pin dependencies to use absolute paths.
# FIXME Hitting compilation issues on Ubuntu 22:

#-- Could NOT find ODBC (missing: ODBC_LIBRARY ODBC_INCLUDE_DIR ODBCINST)
#-- Could NOT find ODBCCPP (missing: ODBCCPP_LIBRARY ODBCCPP_INCLUDE_DIR)
#-- Could NOT find MSSQL_ODBC (missing: MSSQL_ODBC_LIBRARY MSSQL_ODBC_INCLUDE_DIR MSSQL_ODBC_VERSION)
#-- Could NOT find MySQL (missing: MYSQL_LIBRARY MYSQL_INCLUDE_DIR)
#-- Found CURL: /opt/koopa/opt/curl/lib/libcurl.so (found version "7.82.0")
#-- Performing Test Iconv_IS_BUILT_IN
#-- Performing Test Iconv_IS_BUILT_IN - Success
#-- Found Iconv: /usr/lib/x86_64-linux-gnu/libc.so
#-- Performing Test _ICONV_SECOND_ARGUMENT_IS_NOT_CONST
#-- Performing Test _ICONV_SECOND_ARGUMENT_IS_NOT_CONST - Success
#-- Found LibXml2: /opt/koopa/opt/libxml2/lib/libxml2.so
#-- Could NOT find EXPAT (missing: EXPAT_DIR)
#-- Could NOT find EXPAT (missing: EXPAT_LIBRARY EXPAT_INCLUDE_DIR)
#-- Failed to find XercesC (missing: XercesC_LIBRARY XercesC_INCLUDE_DIR XercesC_VERSION)
#-- Could NOT find ZLIB (missing: ZLIB_LIBRARY ZLIB_INCLUDE_DIR)
#-- Could NOT find Deflate (missing: Deflate_LIBRARY Deflate_INCLUDE_DIR)
#-- Found OpenSSL: /opt/koopa/app/openssl3/3.0.5/lib/libcrypto.so (found version "3.0.5") found components: SSL Crypto
#-- Could NOT find CryptoPP (missing: CRYPTOPP_LIBRARY CRYPTOPP_TEST_KNOWNBUG CRYPTOPP_INCLUDE_DIR)
#-- Could NOT find TIFF (missing: TIFF_LIBRARY TIFF_INCLUDE_DIR) (Required is at least version "4.0")
#-- Could NOT find SFCGAL (missing: SFCGAL_LIBRARY SFCGAL_INCLUDE_DIR)
#-- Could NOT find GeoTIFF (missing: GeoTIFF_DIR)
#-- Could NOT find GeoTIFF (missing: GEOTIFF_LIBRARY GEOTIFF_INCLUDE_DIR)
#-- Could NOT find ZLIB (missing: ZLIB_LIBRARY ZLIB_INCLUDE_DIR)
#-- Could NOT find PNG (missing: PNG_LIBRARY PNG_PNG_INCLUDE_DIR)
#-- Could NOT find JPEG (missing: JPEG_LIBRARY JPEG_INCLUDE_DIR)
#-- Could NOT find GIF (missing: GIF_LIBRARY GIF_INCLUDE_DIR)
#-- Could NOT find JSONC (missing: JSONC_DIR)
#-- Could NOT find JSONC (missing: JSONC_LIBRARY JSONC_INCLUDE_DIR)
#-- Could NOT find OpenCAD (missing: OPENCAD_LIBRARY OPENCAD_INCLUDE_DIR)
#-- Could NOT find QHULL (missing: QHULL_LIBRARY QHULL_INCLUDE_DIR)
#-- Could NOT find LERC (missing: LERC_LIBRARY LERC_INCLUDE_DIR)
#-- Could NOT find BRUNSLI (missing: BRUNSLI_ENC_LIB BRUNSLI_DEC_LIB BRUNSLI_INCLUDE_DIR)
#-- Could NOT find Shapelib (missing: Shapelib_INCLUDE_DIR Shapelib_LIBRARY)
#-- Found PCRE2: /opt/koopa/opt/pcre2/lib/libpcre2-8.so
#-- Could NOT find SPATIALITE (missing: SPATIALITE_LIBRARY SPATIALITE_INCLUDE_DIR)
#-- Could NOT find RASTERLITE2 (missing: RASTERLITE2_LIBRARY RASTERLITE2_INCLUDE_DIR)
#-- Could NOT find LibKML (missing: LIBKML_BASE_LIBRARY LIBKML_INCLUDE_DIR LIBKML_DOM_LIBRARY LIBKML_ENGINE_LIBRARY)
#-- HDF5 C compiler wrapper is unable to compile a minimal HDF5 program.
#-- HDF5 CXX compiler wrapper is unable to compile a minimal HDF5 program.
#-- Could NOT find HDF5 (missing: HDF5_LIBRARIES HDF5_INCLUDE_DIRS C CXX) (found version "")



main() {
    # """
    # Install GDAL.
    # @note Updated 2022-07-12.
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
    koopa_activate_build_opt_prefix \
        'cmake' \
        'libtool' \
        'pkg-config'
    koopa_activate_opt_prefix \
        'curl' \
        'geos' \
        'hdf5' \
        'libxml2' \
        'openssl3' \
        'pcre2' \
        'sqlite' \
        'libtiff' \
        'proj' \
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
    cmake_args=(
        '-DBUILD_APPS=ON'
        '-DBUILD_PYTHON_BINDINGS=ON'
        '-DBUILD_SHARED_LIBS=ON'
        '-DCMAKE_BUILD_TYPE=Release'
        "-DCMAKE_INSTALL_PREFIX=${dict[prefix]}"
        "-DCMAKE_INSTALL_RPATH=${dict[prefix]}/lib"
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
        '-DGDAL_USE_TIFF_INTERNAL=ON'
        '-DGDAL_USE_TILEDB=OFF'
        '-DGDAL_USE_WEBP=OFF'
        '-DGDAL_USE_XERCESC=OFF'
        '-DGDAL_USE_ZLIB_INTERNAL=ON'
        '-DGDAL_USE_ZSTD=ON'
        # Required dependency paths.
        # CMake installer currently warns when this is set:
        # > "-DPROJ_INCLUDE_DIR=${dict[opt_prefix]}/proj/include"
        # > "-DPROJ_LIBRARY_RELEASE=${dict[opt_prefix]}/proj/lib/\
# > libproj.${dict[shared_ext]}"
        # Optional dependency paths.
        "-DCURL_INCLUDE_DIR=${dict[opt_prefix]}/curl/include"
        "-DCURL_LIBRARY=${dict[opt_prefix]}/curl/lib/\
libcurl.${dict[shared_ext]}"
        "-DLIBXML2_INCLUDE_DIR=${dict[opt_prefix]}/libxml2/include"
        "-DLIBXML2_LIBRARY=${dict[opt_prefix]}/libxml2/lib/\
libxml2.${dict[shared_ext]}"
        "-DPCRE2_INCLUDE_DIR=${dict[opt_prefix]}/pcre2/include"
        "-DPCRE2_LIBRARY=${dict[opt_prefix]}/pcre2/lib/\
libpcre2-8.${dict[shared_ext]}"
        "-DPython_ROOT=${dict[opt_prefix]}/python"
        "-DSQLite3_INCLUDE_DIR=${dict[opt_prefix]}/sqlite/include"
        "-DSQLite3_LIBRARY=${dict[opt_prefix]}/sqlite/lib/\
libsqlite3.${dict[shared_ext]}"
        # CMake installer currently warns when these are set:
        # > "-DGEOS_INCLUDE_DIR=${dict[opt_prefix]}/geos/include"
        # > "-DGEOS_LIBRARY=${dict[opt_prefix]}/geos/lib/\
# > libgeos.${dict[shared_ext]}"
        # > "-DZSTD_INCLUDE_DIR=${dict[opt_prefix]}/zstd/include"
        # > "-DZSTD_LIBRARY=${dict[opt_prefix]}/zstd/lib/\
# > libzstd.${dict[shared_ext]}"


        "HDF5_LIBRARIES"
        "HDF5_INCLUDE_DIRS"

    )
    koopa_mkdir "${dict[prefix]}/include"
    "${app[cmake]}" .. "${cmake_args[@]}"
    "${app[make]}" --jobs="${dict[jobs]}"
    "${app[make]}" install
    return 0
}
