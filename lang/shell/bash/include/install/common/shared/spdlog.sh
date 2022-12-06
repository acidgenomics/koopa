#!/usr/bin/env bash

main() {
    # """
    # Install spdlog.
    # @note Updated 2022-12-06.
    #
    # @seealso
    # - https://github.com/gabime/spdlog/
    # - https://github.com/Homebrew/homebrew-core/blob/HEAD/Formula/spdlog.rb
    # - https://github.com/conda-forge/spdlog-feedstock
    # - https://raw.githubusercontent.com/archlinux/svntogit-community/
    #     packages/spdlog/trunk/PKGBUILD
    # """
    local app dict shared_cmake_args
    koopa_assert_has_no_args "$#"
    koopa_activate_app --build-only 'cmake' 'pkg-config'
    koopa_activate_app 'fmt'
    declare -A app=(
        ['cmake']="$(koopa_locate_cmake)"
        ['ctest']="$(koopa_locate_ctest)"
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
    shared_cmake_args=(
        "-DCMAKE_INSTALL_PREFIX=${dict['prefix']}"
        '-DCMAKE_INSTALL_INCLUDEDIR=include'
        '-DCMAKE_INSTALL_LIBDIR=lib'
        "-DCMAKE_INSTALL_RPATH=${dict['prefix']}/lib"
        '-DSPDLOG_BUILD_BENCH=OFF'
        '-DSPDLOG_BUILD_TESTS=ON'
        '-DSPDLOG_FMT_EXTERNAL=ON'
        "-Dfmt_DIR=${dict['fmt']}/lib/cmake/fmt"
        # FIXME Does adding these harden our build?
        '-DCMAKE_BUILD_TYPE=Release'
        "-DCMAKE_CXX_FLAGS=${CPPFLAGS:-}"
        "-DCMAKE_C_FLAGS=${CFLAGS:-}" # FIXME Take out
        "-DCMAKE_EXE_LINKER_FLAGS=${LDFLAGS:-}"
        "-DCMAKE_MODULE_LINKER_FLAGS=${LDFLAGS:-}"
        "-DCMAKE_SHARED_LINKER_FLAGS=${LDFLAGS:-}"
        '-Wno-dev'
    )
    koopa_print_env
    koopa_dl 'Shared CMake args' "${shared_cmake_args[*]}"
    "${app['cmake']}" -LH \
        -S . \
        -B 'build-shared' \
        "${shared_cmake_args[@]}" \
        -DSPDLOG_BUILD_SHARED='ON'
    "${app['cmake']}" \
        --build 'build-shared' \
        --parallel "${dict['jobs']}"
    "${app['ctest']}" \
        --parallel "${dict['jobs']}" \
        --stop-on-failure \
        --test-dir 'build-shared' \
        --verbose
    "${app['cmake']}" --install 'build-shared'
    "${app['cmake']}" -LH \
        -S . \
        -B 'build-static' \
        "${shared_cmake_args[@]}" \
        -DSPDLOG_BUILD_SHARED='OFF'
    "${app['cmake']}" \
        --build 'build-static' \
        --parallel "${dict['jobs']}"
    "${app['ctest']}" \
        --parallel "${dict['jobs']}" \
        --stop-on-failure \
        --test-dir 'build-static' \
        --verbose
    "${app['cmake']}" --install 'build-static'
    koopa_assert_is_file "${dict['prefix']}/lib/libspdlog.a"
    return 0
}
