#!/usr/bin/env bash

main() {
    # """
    # Install zstd.
    # @note Updated 2023-03-07.
    #
    # @seealso
    # - https://facebook.github.io/zstd/
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/zstd.rb
    # """
    local app cmake_args dict
    koopa_assert_has_no_args "$#"
    koopa_activate_app --build-only 'cmake'
    koopa_activate_app 'lz4' 'zlib'
    declare -A app
    app['cmake']="$(koopa_locate_cmake)"
    [[ -x "${app['cmake']}" ]] || return 1
    declare -A dict=(
        ['jobs']="$(koopa_cpu_count)"
        ['lz4']="$(koopa_app_prefix 'lz4')"
        ['name']='zstd'
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
        ['shared_ext']="$(koopa_shared_ext)"
        ['version']="${KOOPA_INSTALL_VERSION:?}"
        ['zlib']="$(koopa_app_prefix 'zlib')"
    )
    dict['file']="v${dict['version']}.tar.gz"
    dict['url']="https://github.com/facebook/${dict['name']}/\
archive/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd "${dict['name']}-${dict['version']}"
    cmake_args=(
        '-DCMAKE_BUILD_TYPE=Release'
        '-DCMAKE_CXX_STANDARD=11'
        "-DCMAKE_INSTALL_PREFIX=${dict['prefix']}"
        "-DCMAKE_INSTALL_RPATH=${dict['prefix']}/lib"
        '-DZSTD_BUILD_CONTRIB=ON'
        '-DZSTD_LEGACY_SUPPORT=ON'
        '-DZSTD_LZ4_SUPPORT=ON'
        '-DZSTD_LZMA_SUPPORT=OFF'
        '-DZSTD_PROGRAMS_LINK_SHARED=ON'
        '-DZSTD_ZLIB_SUPPORT=ON'
        # External dependencies.
        "-DLIBLZ4_INCLUDE_DIR=${dict['lz4']}/include"
        "-DLIBLZ4_LIBRARY=${dict['lz4']}/lib/liblz4.${dict['shared_ext']}"
        "-DZLIB_INCLUDE_DIR=${dict['zlib']}/include"
        "-DZLIB_LIBRARY=${dict['zlib']}/lib/libz.${dict['shared_ext']}"
    )
    koopa_print_env
    koopa_dl 'CMake args' "${cmake_args[*]}"
    "${app['cmake']}" -LH \
        '-S' 'build/cmake' \
        '-B' 'builddir' \
        "${cmake_args[@]}"
    "${app['cmake']}" \
        --build 'builddir' \
        --parallel "${dict['jobs']}"
    "${app['cmake']}" --install 'builddir'
    return 0
}
