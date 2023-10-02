#!/usr/bin/env bash

main() {
    # """
    # Install pybind11.
    # @note Updated 2023-04-06.
    #
    # @seealso
    # - https://pybind11.readthedocs.io/en/stable/compiling.html
    # """
    local -A dict
    local -a cmake_args
    koopa_activate_app --build-only 'python3.12'
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    cmake_args=(
        '-DPYBIND11_NOPYTHON=ON'
        '-DPYBIND11_TEST=OFF'
    )
    dict['url']="https://github.com/pybind/pybind11/archive/\
v${dict['version']}.tar.gz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    koopa_cmake_build --prefix="${dict['prefix']}" "${cmake_args[@]}"
    return 0
}
