#!/usr/bin/env bash

main() {
    # """
    # Install fmt library.
    # @note Updated 2022-12-06.
    #
    # @seealso
    # - https://github.com/fmtlib/fmt
    # - https://github.com/Homebrew/homebrew-core/blob/HEAD/Formula/fmt.rb
    # """
    local app dict shared_cmake_args
    koopa_assert_has_no_args "$#"
    koopa_activate_app --build-only 'cmake'
    declare -A app=(
        ['cmake']="$(koopa_locate_cmake)"
    )
    [[ -x "${app['cmake']}" ]] || return 1
    declare -A dict=(
        ['jobs']="$(koopa_cpu_count)"
        ['name']='fmt'
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
        ['version']="${KOOPA_INSTALL_VERSION:?}"
    )
    dict['file']="${dict['version']}.tar.gz"
    dict['url']="https://github.com/fmtlib/${dict['name']}/archive/refs/\
tags/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd "${dict['name']}-${dict['version']}"
    shared_cmake_args=(
        "-DCMAKE_INSTALL_PREFIX=${dict['prefix']}"
        "-DCMAKE_INSTALL_RPATH=${dict['prefix']}/lib"
        # FIXME Does adding these harden our build?
        '-DCMAKE_BUILD_TYPE=Release'
        "-DCMAKE_CXX_FLAGS=${CPPFLAGS:-}"
        "-DCMAKE_C_FLAGS=${CFLAGS:-}"
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
        -DBUILD_SHARED_LIBS='TRUE'
    "${app['cmake']}" \
        --build 'build-shared' \
        --parallel "${dict['jobs']}"
    "${app['cmake']}" --install 'build-shared'
    "${app['cmake']}" -LH \
        -S . \
        -B 'build-static' \
        "${shared_cmake_args[@]}" \
        -DBUILD_SHARED_LIBS='FALSE'
    "${app['cmake']}" \
        --build 'build-static' \
        --parallel "${dict['jobs']}"
    "${app['cmake']}" --install 'build-static'
    koopa_assert_is_file "${dict['prefix']}/lib/libfmt.a"
    return 0
}
