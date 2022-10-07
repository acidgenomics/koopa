#!/usr/bin/env bash

main() {
    # """
    # Install TagLib.
    # @note Updated 2022-09-12.
    #
    # To build a static library, set the following two options with CMake:
    # -DBUILD_SHARED_LIBS=OFF -DENABLE_STATIC_RUNTIME=ON
    #
    # How to set '-fPIC' compiler flags?
    # -DCMAKE_CXX_FLAGS='-fpic'
    #
    # Enable for unit tests with 'make check':
    # -DBUILD_TESTS='on'
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
    koopa_activate_build_opt_prefix 'cmake'
    declare -A app=(
        ['cmake']="$(koopa_locate_cmake)"
    )
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
        '-DCMAKE_BUILD_TYPE=Release'
        '-DCMAKE_CXX_FLAGS=-fpic'
        "-DCMAKE_INSTALL_PREFIX=${dict['prefix']}"
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
