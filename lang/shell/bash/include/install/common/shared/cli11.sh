#!/usr/bin/env bash

main() {
    # """
    # Install CLI11.
    # @note Updated 2023-03-30.
    #
    # @seealso
    # - https://github.com/Homebrew/homebrew-core/blob/HEAD/Formula/cli11.rb
    # """
    local dict
    koopa_assert_has_no_args "$#"
    koopa_activate_app --build-only 'pkg-config'
    local -A dict=(
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
        ['version']="${KOOPA_INSTALL_VERSION:?}"
    )
    cmake_args=(
        '-DCLI11_BUILD_DOCS=OFF'
        '-DCLI11_BUILD_TESTS=OFF'
    )
    dict['url']="https://github.com/CLIUtils/CLI11/archive/\
v${dict['version']}.tar.gz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    koopa_cmake_build --prefix="${dict['prefix']}" "${cmake_args[@]}"
    return 0
}
