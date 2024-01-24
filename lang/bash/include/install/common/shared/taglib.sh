#!/usr/bin/env bash

main() {
    # """
    # Install TagLib.
    # @note Updated 2024-01-24.
    #
    # @seealso
    # - https://stackoverflow.com/questions/29200461
    # - https://stackoverflow.com/questions/38296756
    # - https://github.com/taglib/taglib/blob/master/INSTALL.md
    # - https://github.com/eplightning/audiothumbs-frameworks/issues/2
    # - https://cmake.org/pipermail/cmake/2012-June/050792.html
    # - https://github.com/gabime/spdlog/issues/1190
    # """
    local -A app cmake dict
    local -a cmake_args
    app['git']="$(koopa_locate_git)"
    koopa_assert_is_executable "${app[@]}"
    koopa_activate_app --build-only 'pkg-config'
    koopa_activate_app 'zlib'
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['shared_ext']="$(koopa_shared_ext)"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['zlib']="$(koopa_app_prefix 'zlib')"
    koopa_assert_is_dir "${dict['zlib']}"
    cmake['zlib_include_dir']="${dict['zlib']}/include"
    cmake['zlib_library']="${dict['zlib']}/lib/libz.${dict['shared_ext']}"
    koopa_assert_is_dir "${cmake['zlib_include_dir']}"
    koopa_assert_is_file "${cmake['zlib_library']}"
    cmake_args=(
        # Build options --------------------------------------------------------
        '-DBUILD_SHARED_LIBS=ON'
        '-DBUILD_TESTS=OFF'
        '-DNO_ITUNES_HACKS=ON'
        '-DWITH_ZLIB=ON'
        # Dependency paths -----------------------------------------------------
        "-DZLIB_INCLUDE_DIR=${cmake['zlib_include_dir']}"
        "-DZLIB_LIBRARY=${cmake['zlib_library']}"
    )
    koopa_git_clone \
        --prefix='src' \
        --tag="v${dict['version']}" \
        --url='https://github.com/taglib/taglib'
    koopa_cd 'src'
    # Required for 'utfcpp' submodule as of v2.0 release.
    "${app['git']}" submodule update --init
    koopa_cmake_build \
        --include-dir='include' \
        --lib-dir='lib' \
        --prefix="${dict['prefix']}" \
        "${cmake_args[@]}"
    return 0
}
