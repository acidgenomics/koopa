#!/usr/bin/env bash

main() {
    # """
    # Install TagLib.
    # @note Updated 2023-03-26.
    #
    # @seealso
    # - https://stackoverflow.com/questions/29200461
    # - https://stackoverflow.com/questions/38296756
    # - https://github.com/taglib/taglib/blob/master/INSTALL.md
    # - https://github.com/eplightning/audiothumbs-frameworks/issues/2
    # - https://cmake.org/pipermail/cmake/2012-June/050792.html
    # - https://github.com/gabime/spdlog/issues/1190
    # """
    local app cmake_args dict
    koopa_assert_has_no_args "$#"
    koopa_activate_app --build-only 'cmake' 'pkg-config'
    declare -A app
    app['cmake']="$(koopa_locate_cmake)"
    [[ -x "${app['cmake']}" ]] || return 1
    declare -A dict=(
        ['jobs']="$(koopa_cpu_count)"
        ['name']='taglib'
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
        ['version']="${KOOPA_INSTALL_VERSION:?}"
    )
    dict['file']="v${dict['version']}.tar.gz"
    dict['url']="https://github.com/${dict['name']}/${dict['name']}/\
archive/refs/tags/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd "${dict['name']}-${dict['version']}"
    cmake_args=(
        # Standard CMake arguments ---------------------------------------------
        '-DCMAKE_BUILD_TYPE=Release'
        "-DCMAKE_CXX_FLAGS=-fPIC ${CXXFLAGS:-}"
        "-DCMAKE_INSTALL_PREFIX=${dict['prefix']}"
        '-DCMAKE_VERBOSE_MAKEFILE=ON'
        # Build options --------------------------------------------------------
        '-DBUILD_TESTS=OFF'
    )
    koopa_print_env
    koopa_dl 'CMake args' "${cmake_args[*]}"
    "${app['cmake']}" -LH \
        -S . \
        -B 'build' \
        "${cmake_args[@]}"
    "${app['cmake']}" \
        --build 'build' \
        --parallel "${dict['jobs']}"
    "${app['cmake']}" --install 'build'
    return 0
}
