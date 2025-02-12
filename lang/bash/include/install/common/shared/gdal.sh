#!/usr/bin/env bash

# NOTE May need to address this:
# -- Performing Test HAVE_JPEGTURBO_DUAL_MODE_8_12
# -- Performing Test HAVE_JPEGTURBO_DUAL_MODE_8_12 - Failed

main() {
    # """
    # Install GDAL.
    # @note Updated 2023-05-11.
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
    local -A cmake dict
    local -a build_deps cmake_args deps
    build_deps=('libtool' 'pkg-config')
    deps=(
        'zlib'
        'zstd'
        'bison'
        'expat'
        'geos'
        'hdf5'
        'libdeflate'
        'libiconv'
        'libjpeg-turbo'
        'libpng'
        'libtiff'
        'icu4c75' # libxml2
        'libxml2'
        'lz4'
        'openjpeg'
        'openssl3'
        'pcre2'
        'sqlite'
        'xz'
        'zlib'
        'zstd'
        'libssh2' # curl
        'curl'
        'proj'
    )
    koopa_activate_app --build-only "${build_deps[@]}"
    koopa_activate_app "${deps[@]}"
    dict['curl']="$(koopa_app_prefix 'curl')"
    dict['expat']="$(koopa_app_prefix 'expat')"
    dict['hdf5']="$(koopa_app_prefix 'hdf5')"
    dict['libdeflate']="$(koopa_app_prefix 'libdeflate')"
    dict['libiconv']="$(koopa_app_prefix 'libiconv')"
    dict['libpng']="$(koopa_app_prefix 'libpng')"
    dict['libtiff']="$(koopa_app_prefix 'libtiff')"
    dict['libxml2']="$(koopa_app_prefix 'libxml2')"
    dict['lz4']="$(koopa_app_prefix 'lz4')"
    dict['openjpeg']="$(koopa_app_prefix 'openjpeg')"
    dict['pcre2']="$(koopa_app_prefix 'pcre2')"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['proj']="$(koopa_app_prefix 'proj')"
    dict['shared_ext']="$(koopa_shared_ext)"
    dict['sqlite']="$(koopa_app_prefix 'sqlite')"
    dict['temurin']="$(koopa_app_prefix 'temurin')"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['xz']="$(koopa_app_prefix 'xz')"
    dict['zlib']="$(koopa_app_prefix 'zlib')"
    dict['zstd']="$(koopa_app_prefix 'zstd')"
    cmake['curl_include_dir']="${dict['curl']}/include"
    cmake['curl_library']="${dict['curl']}/lib/\
libcurl.${dict['shared_ext']}"
    cmake['deflate_include_dir']="${dict['libdeflate']}/include"
    cmake['deflate_library']="${dict['libdeflate']}/lib/\
libdeflate.${dict['shared_ext']}"
    cmake['expat_dir']="${dict['expat']}"
    cmake['hdf5_root']="${dict['hdf5']}"
    cmake['iconv_include_dir']="${dict['libiconv']}/include"
    cmake['iconv_library']="${dict['libiconv']}/lib/\
libiconv.${dict['shared_ext']}"
    cmake['liblzma_include_dir']="${dict['xz']}/include"
    cmake['liblzma_library']="${dict['xz']}/lib/liblzma.${dict['shared_ext']}"
    cmake['libxml2_include_dir']="${dict['libxml2']}/include"
    cmake['libxml2_library']="${dict['libxml2']}/lib/\
libxml2.${dict['shared_ext']}"
    cmake['lz4_include_dir']="${dict['lz4']}/include"
    cmake['lz4_library']="${dict['lz4']}/lib/liblz4.${dict['shared_ext']}"
    cmake['openjpeg_include_dir']="${dict['openjpeg']}/include"
    cmake['openjpeg_library']="${dict['openjpeg']}/lib/\
libopenjp2.${dict['shared_ext']}"
    cmake['pcre2_include_dir']="${dict['pcre2']}/include"
    cmake['pcre2_8_library']="${dict['pcre2']}/lib/\
libpcre2-8.${dict['shared_ext']}"
    cmake['png_include_dir']="${dict['libpng']}/include"
    cmake['png_library']="${dict['libpng']}/lib/libpng.${dict['shared_ext']}"
    cmake['proj_dir']="${dict['proj']}/lib/cmake/proj"
    cmake['proj_include_dir']="${dict['proj']}/include"
    cmake['proj_library']="${dict['proj']}/lib/\
libproj.${dict['shared_ext']}"
    cmake['sqlite3_include_dir']="${dict['sqlite']}/include"
    cmake['sqlite3_library']="${dict['sqlite']}/lib/\
libsqlite3.${dict['shared_ext']}"
    cmake['tiff_include_dir']="${dict['libtiff']}/include"
    cmake['tiff_library_release']="${dict['libtiff']}/lib/\
libtiff.${dict['shared_ext']}"
    cmake['zlib_include_dir']="${dict['zlib']}/include"
    cmake['zlib_library']="${dict['zlib']}/lib/libz.${dict['shared_ext']}"
    cmake['zstd_dir']="${dict['zstd']}/lib/cmake/zstd"
    koopa_assert_is_dir \
        "${cmake['curl_include_dir']}" \
        "${cmake['deflate_include_dir']}" \
        "${cmake['expat_dir']}" \
        "${cmake['hdf5_root']}" \
        "${cmake['iconv_include_dir']}" \
        "${cmake['liblzma_include_dir']}" \
        "${cmake['libxml2_include_dir']}" \
        "${cmake['lz4_include_dir']}" \
        "${cmake['openjpeg_include_dir']}" \
        "${cmake['pcre2_include_dir']}" \
        "${cmake['png_include_dir']}" \
        "${cmake['proj_dir']}" \
        "${cmake['proj_include_dir']}" \
        "${cmake['sqlite3_include_dir']}" \
        "${cmake['tiff_include_dir']}" \
        "${cmake['zlib_include_dir']}" \
        "${cmake['zstd_dir']}"
    koopa_assert_is_file \
        "${cmake['curl_library']}" \
        "${cmake['deflate_library']}" \
        "${cmake['iconv_library']}" \
        "${cmake['liblzma_library']}" \
        "${cmake['libxml2_library']}" \
        "${cmake['lz4_library']}" \
        "${cmake['openjpeg_library']}" \
        "${cmake['pcre2_8_library']}" \
        "${cmake['png_library']}" \
        "${cmake['proj_library']}" \
        "${cmake['sqlite3_library']}" \
        "${cmake['tiff_library_release']}" \
        "${cmake['zlib_library']}"
    cmake_args=(
        # Build options --------------------------------------------------------
        '-DBUILD_APPS=ON'
        '-DBUILD_JAVA_BINDINGS=OFF'
        '-DBUILD_PYTHON_BINDINGS=OFF'
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
        "-DCURL_INCLUDE_DIR=${cmake['curl_include_dir']}"
        "-DCURL_LIBRARY=${cmake['curl_library']}"
        "-DDeflate_INCLUDE_DIR=${cmake['deflate_include_dir']}"
        "-DDeflate_LIBRARY=${cmake['deflate_library']}"
        "-DEXPAT_DIR=${cmake['expat_dir']}"
        "-DHDF5_ROOT=${cmake['hdf5_root']}"
        "-DIconv_INCLUDE_DIR=${cmake['iconv_include_dir']}"
        "-DIconv_LIBRARY=${cmake['iconv_library']}"
        "-DLIBLZMA_INCLUDE_DIR=${cmake['liblzma_include_dir']}"
        "-DLIBLZMA_LIBRARY=${cmake['liblzma_library']}"
        "-DLIBXML2_INCLUDE_DIR=${cmake['libxml2_include_dir']}"
        "-DLIBXML2_LIBRARY=${cmake['libxml2_library']}"
        "-DLZ4_INCLUDE_DIR=${cmake['lz4_include_dir']}"
        "-DLZ4_LIBRARY=${cmake['lz4_library']}"
        "-DOPENJPEG_INCLUDE_DIR=${cmake['openjpeg_include_dir']}"
        "-DOPENJPEG_LIBRARY=${cmake['openjpeg_library']}"
        "-DPCRE2-8_LIBRARY=${cmake['pcre2_8_library']}"
        "-DPCRE2_INCLUDE_DIR=${cmake['pcre2_include_dir']}"
        "-DPNG_INCLUDE_DIR=${cmake['png_include_dir']}"
        "-DPNG_LIBRARY=${cmake['png_library']}"
        "-DPROJ_DIR=${cmake['proj_dir']}"
        "-DPROJ_INCLUDE_DIR=${cmake['proj_include_dir']}"
        "-DPROJ_LIBRARY=${cmake['proj_library']}"
        "-DSQLite3_INCLUDE_DIR=${cmake['sqlite3_include_dir']}"
        "-DSQLite3_LIBRARY=${cmake['sqlite3_library']}"
        "-DTIFF_INCLUDE_DIR=${cmake['tiff_include_dir']}"
        "-DTIFF_LIBRARY_RELEASE=${cmake['tiff_library_release']}"
        "-DZLIB_INCLUDE_DIR=${cmake['zlib_include_dir']}"
        "-DZLIB_LIBRARY=${cmake['zlib_library']}"
        "-DZSTD_DIR=${cmake['zstd_dir']}"
    )
    dict['url']="https://github.com/OSGeo/gdal/releases/download/\
v${dict['version']}/gdal-${dict['version']}.tar.gz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    koopa_mkdir "${dict['prefix']}/include"
    koopa_cmake_build --prefix="${dict['prefix']}" "${cmake_args[@]}"
    return 0
}
