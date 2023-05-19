#!/usr/bin/env bash

# NOTE Consider adding support for GTest here.

main() {
    # """
    # Install msgpack.
    # @note Updated 2023-04-06.
    #
    # - @seealso
    # - https://github.com/Homebrew/homebrew-core/blob/HEAD/Formula/msgpack.rb
    # """
    local -A dict
    local -a cmake_args
    koopa_activate_app 'boost'
    dict['boost']="$(koopa_app_prefix 'boost')"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    koopa_assert_is_dir "${dict['boost']}"
    cmake_args=(
        "-DBoost_INCLUDE_DIR=${dict['boost']}/include"
    )
    dict['url']="https://github.com/msgpack/msgpack-c/releases/download/\
cpp-${dict['version']}/msgpack-cxx-${dict['version']}.tar.gz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    koopa_cmake_build --prefix="${dict['prefix']}" "${cmake_args[@]}"
    return 0
}
