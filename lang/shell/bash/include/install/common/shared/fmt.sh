#!/usr/bin/env bash

main() {
    # """
    # Install fmt library.
    # @note Updated 2022-12-06.
    #
    # @seealso
    # - https://github.com/fmtlib/fmt
    # - https://github.com/Homebrew/homebrew-core/blob/HEAD/Formula/fmt.rb
    # - https://github.com/conda-forge/fmt-feedstock
    # """
    local app dict shared_cmake_args
    koopa_assert_has_no_args "$#"
    koopa_activate_app --build-only 'cmake'
    declare -A app=(
        ['cmake']="$(koopa_locate_cmake)"
        ['make']="$(koopa_locate_make)"
    )
    [[ -x "${app['cmake']}" ]] || return 1
    [[ -x "${app['make']}" ]] || return 1
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
        '-DCMAKE_BUILD_TYPE=Release'
        "-DCMAKE_CXX_FLAGS=${CPPFLAGS:-}"
        "-DCMAKE_EXE_LINKER_FLAGS=${LDFLAGS:-}"
        '-DCMAKE_INSTALL_LIBDIR=lib'
        "-DCMAKE_INSTALL_PREFIX=${dict['prefix']}"
        "-DCMAKE_INSTALL_RPATH=${dict['prefix']}/lib"
        "-DCMAKE_MODULE_LINKER_FLAGS=${LDFLAGS:-}"
        "-DCMAKE_SHARED_LINKER_FLAGS=${LDFLAGS:-}"
        '-DFMT_DOC=OFF'
        '-DFMT_INSTALL=ON'
        '-DFMT_PEDANTIC=ON'
        '-DFMT_SYSTEM_HEADERS=ON'
        '-DFMT_TEST=ON'
        '-DFMT_WERROR=ON'
    )
    koopa_print_env
    koopa_dl 'Shared CMake args' "${shared_cmake_args[*]}"
    "${app['cmake']}" -LH \
        -S . \
        -B 'build-shared' \
        "${shared_cmake_args[@]}" \
        -DBUILD_SHARED_LIBS='TRUE'
    "${app['make']}" \
        --directory='build-shared' \
        --jobs="${dict['jobs']}" \
        install
    "${app['cmake']}" -LH \
        -S . \
        -B 'build-static' \
        "${shared_cmake_args[@]}" \
        -DBUILD_SHARED_LIBS='FALSE'
    "${app['make']}" \
        --directory='build-static' \
        --jobs="${dict['jobs']}" \
        install
    koopa_assert_is_file "${dict['prefix']}/lib/libfmt.a"
    return 0
}
