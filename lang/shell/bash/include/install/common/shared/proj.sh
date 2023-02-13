#!/usr/bin/env bash

main() {
    # """
    # Install PROJ.
    # @note Updated 2023-01-04.
    #
    # Alternative approach for SQLite3 dependency:
    # > -DCMAKE_PREFIX_PATH='/opt/koopa/opt/sqlite'
    #
    # @seealso
    # - https://proj.org/install.html#cmake-configure-options
    # - https://github.com/OSGeo/PROJ/issues/2084
    # - https://github.com/tesseract-ocr/tesseract/issues/786
    # """
    local app cmake_args dict
    koopa_assert_has_no_args "$#"
    # > if koopa_is_linux
    # > then
    # >     koopa_assert_is_non_existing \
    # >         '/usr/include/proj' \
    # >         '/usr/include/proj.h' \
    # >         '/usr/lib/x86_64-linux-gnu/pkgconfig/proj.pc'
    # > fi
    koopa_activate_app --build-only 'pkg-config'
    koopa_activate_app \
        'curl' \
        'zlib' \
        'zstd' \
        'libjpeg-turbo' \
        'libtiff' \
        'python3.11' \
        'sqlite'
    declare -A app=(
        ['cmake']="$(koopa_locate_cmake)"
        ['make']="$(koopa_locate_make)"
    )
    [[ -x "${app['cmake']}" ]] || return 1
    [[ -x "${app['make']}" ]] || return 1
    declare -A dict=(
        ['jobs']="$(koopa_cpu_count)"
        ['make_prefix']="$(koopa_make_prefix)"
        ['name']='proj'
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
        ['shared_ext']="$(koopa_shared_ext)"
        ['version']="${KOOPA_INSTALL_VERSION:?}"
    )
    dict['file']="${dict['name']}-${dict['version']}.tar.gz"
    dict['url']="https://github.com/OSGeo/PROJ/releases/download/\
${dict['version']}/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd "${dict['name']}-${dict['version']}"
    koopa_mkdir 'build'
    koopa_cd 'build'
    dict['curl']="$(koopa_app_prefix 'curl')"
    dict['libtiff']="$(koopa_app_prefix 'libtiff')"
    dict['sqlite']="$(koopa_app_prefix 'sqlite')"
    cmake_args=(
        '-DBUILD_APPS=ON'
        '-DBUILD_FRAMEWORKS_AND_BUNDLE=OFF'
        '-DBUILD_SHARED_LIBS=ON'
        '-DBUILD_TESTING=OFF'
        '-DCMAKE_BUILD_TYPE=Release'
        "-DCMAKE_CXX_FLAGS=${CPPFLAGS:-}"
        "-DCMAKE_C_FLAGS=${CFLAGS:-}"
        "-DCMAKE_EXE_LINKER_FLAGS=${LDFLAGS:-}"
        "-DCMAKE_INSTALL_PREFIX=${dict['prefix']}"
        "-DCMAKE_INSTALL_RPATH=${dict['prefix']}/lib"
        "-DCMAKE_MODULE_LINKER_FLAGS=${LDFLAGS:-}"
        "-DCMAKE_SHARED_LINKER_FLAGS=${LDFLAGS:-}"
        '-DENABLE_CURL=ON'
        '-DENABLE_TIFF=ON'
        # Required dependency paths.
        "-DEXE_SQLITE3=${dict['sqlite']}/bin/sqlite3"
        "-DSQLITE3_INCLUDE_DIR=${dict['sqlite']}/include"
        "-DSQLITE3_LIBRARY=${dict['sqlite']}/lib/\
libsqlite3.${dict['shared_ext']}"
        # Optional dependency paths.
        "-DCURL_INCLUDE_DIR=${dict['curl']}/include"
        "-DCURL_LIBRARY=${dict['curl']}/lib/libcurl.${dict['shared_ext']}"
        "-DTIFF_INCLUDE_DIR=${dict['libtiff']}/include"
        "-DTIFF_LIBRARY_RELEASE=${dict['libtiff']}/lib/\
libtiff.${dict['shared_ext']}"
    )
    koopa_print_env
    koopa_dl 'CMake args' "${cmake_args[*]}"
    "${app['cmake']}" -LH -S .. "${cmake_args[@]}"
    "${app['make']}" VERBOSE=1 --jobs="${dict['jobs']}"
    "${app['make']}" install
    return 0
}
