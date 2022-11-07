#!/usr/bin/env bash

main() {
    # """
    # Install spdlog.
    # @note Updated 2022-11-04.
    #
    # @seealso
    # - https://github.com/gabime/spdlog/
    # - https://github.com/Homebrew/homebrew-core/blob/HEAD/Formula/spdlog.rb
    # """
    local app cmake_args dict
    koopa_assert_has_no_args "$#"
    koopa_activate_app --build-only 'cmake' 'pkg-config'
    koopa_activate_app 'fmt'
    declare -A app=(
        ['cmake']="$(koopa_locate_cmake)"
    )
    [[ -x "${app['cmake']}" ]] || return 1
    declare -A dict=(
        ['fmt']="$(koopa_app_prefix 'fmt')"
        ['jobs']="$(koopa_cpu_count)"
        ['name']='spdlog'
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
        ['version']="${KOOPA_INSTALL_VERSION:?}"
    )
    koopa_assert_is_dir "${dict['fmt']}"
    dict['file']="v${dict['version']}.tar.gz"
    dict['url']="https://github.com/gabime/${dict['name']}/\
archive/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd "${dict['name']}-${dict['version']}"
    cmake_args=(
        "-DCMAKE_INSTALL_PREFIX=${dict['prefix']}"
        '-DCMAKE_INSTALL_INCLUDEDIR=include'
        '-DCMAKE_INSTALL_LIBDIR=lib'
        '-DSPDLOG_BUILD_BENCH=OFF'
        '-DSPDLOG_BUILD_SHARED=ON'
        '-DSPDLOG_BUILD_TESTS=OFF'
        '-DSPDLOG_FMT_EXTERNAL=ON'
        # This is mutually exclusive with 'SPDLOG_FMT_EXTERNAL'.
        # > '-DSPDLOG_FMT_EXTERNAL_HO=ON'
        "-Dfmt_DIR=${dict['fmt']}/lib/cmake/fmt"
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
