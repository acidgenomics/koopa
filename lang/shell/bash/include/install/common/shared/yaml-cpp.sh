#!/usr/bin/env bash

main() {
    # """
    # Install yaml-cpp.
    # @note Updated 2023-03-31.
    #
    # @seealso
    # - https://github.com/Homebrew/homebrew-core/blob/HEAD/Formula/yaml-cpp.rb
    # """
    local cmake_args dict
    koopa_assert_has_no_args "$#"
    koopa_activate_app --build-only 'pkg-config'
    declare -A dict=(
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
        ['version']="${KOOPA_INSTALL_VERSION:?}"
    )
    dict['url']="https://github.com/jbeder/yaml-cpp/archive/\
yaml-cpp-${dict['version']}.tar.gz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    cmake_args=(
        '-DYAML_BUILD_SHARED_LIBS=ON'
        '-DYAML_CPP_BUILD_TESTS=OFF'
    )
    koopa_cmake_build --prefix="${dict['prefix']}" "${cmake_args[@]}"
    return 0
}
