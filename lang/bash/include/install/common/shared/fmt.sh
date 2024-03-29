#!/usr/bin/env bash

main() {
    # """
    # Install fmt library.
    # @note Updated 2023-05-11.
    #
    # @seealso
    # - https://github.com/fmtlib/fmt
    # - https://github.com/Homebrew/homebrew-core/blob/HEAD/Formula/fmt.rb
    # - https://github.com/conda-forge/fmt-feedstock
    # """
    local -A dict
    local -a cmake_args
    koopa_activate_app --build-only 'pkg-config'
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    cmake_args=(
        # > '-DFMT_PEDANTIC=ON'
        # > '-DFMT_SYSTEM_HEADERS=ON'
        # > '-DFMT_WERROR=ON'
        '-DBUILD_SHARED_LIBS=ON'
        '-DFMT_DOC=OFF'
        '-DFMT_INSTALL=ON'
        '-DFMT_TEST=ON'
    )
    dict['url']="https://github.com/fmtlib/fmt/archive/refs/tags/\
${dict['version']}.tar.gz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    koopa_cmake_build --prefix="${dict['prefix']}" "${cmake_args[@]}"
    return 0
}
