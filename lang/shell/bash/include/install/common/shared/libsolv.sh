#!/usr/bin/env bash

main() {
    # """
    # Install libsolv.
    # @note Updated 2022-11-03.
    #
    # @seealso
    # - https://github.com/openSUSE/libsolv
    # """
    local app cmake_args dict
    koopa_assert_has_no_args "$#"
    koopa_activate_app --build-only 'pkg-config'
    declare -A app=(
        ['cmake']="$(koopa_locate_cmake)"
        ['make']="$(koopa_locate_make)"
    )
    [[ -x "${app['cmake']}" ]] || return 1
    [[ -x "${app['make']}" ]] || return 1
    declare -A dict=(
        ['name']='libsolv'
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
        ['version']="${KOOPA_INSTALL_VERSION:?}"
    )
    dict['file']="${dict['version']}.tar.gz"
    dict['url']="https://github.com/openSUSE/${dict['name']}/archive/refs/\
tags/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd "${dict['name']}-${dict['version']}"
    koopa_print_env
    cmake_args=(
        "-DCMAKE_INSTALL_PREFIX=${dict['prefix']}"
    )
    koopa_dl 'CMake args' "${cmake_args[*]}"
    koopa_mkdir 'build'
    koopa_cd 'build'
    "${app['cmake']}" -LH -S .. "${cmake_args[@]}"
    "${app['make']}"
    "${app['make']}" install
    return 0
}
