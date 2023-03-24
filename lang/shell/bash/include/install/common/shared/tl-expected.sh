#!/usr/bin/env bash

# FIXME This is failing to build on Ubuntu 22?

main() {
    # """
    # Install TartanLlama expected (tl-expected).
    # @note Updated 2023-03-24.
    #
    # @seealso
    # - https://github.com/TartanLlama/expected
    # """
    local app cmake_args dict
    koopa_assert_has_no_args "$#"
    koopa_activate_app --build-only 'cmake'
    declare -A app=(
        ['cmake']="$(koopa_locate_cmake)"
    )
    [[ -x "${app['cmake']}" ]] || return 1
    declare -A dict=(
        ['jobs']="$(koopa_cpu_count)"
        ['name']='expected'
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
        ['version']="${KOOPA_INSTALL_VERSION:?}"
    )
    dict['file']="v${dict['version']}.tar.gz"
    dict['url']="https://github.com/TartanLlama/${dict['name']}/archive/\
refs/tags/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd "${dict['name']}-${dict['version']}"
    cmake_args=(
        # Standard CMake arguments ---------------------------------------------
        "-DCMAKE_INSTALL_PREFIX=${dict['prefix']}"
        '-DCMAKE_VERBOSE_MAKEFILE=ON'
        # Build options --------------------------------------------------------
        '-DEXPECTED_ENABLE_TESTS=OFF'
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
