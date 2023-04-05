#!/usr/bin/env bash

main() {
    # """
    # Install c-ares.
    # @note Updated 2023-03-30.
    #
    # @seealso
    # - https://c-ares.org/
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/c-ares.rb
    # """
    local dict
    koopa_assert_has_no_args "$#"
    koopa_activate_app --build-only 'pkg-config'
    local -A dict=(
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
        ['version']="${KOOPA_INSTALL_VERSION:?}"
    )
    dict['url']="https://c-ares.org/download/c-ares-${dict['version']}.tar.gz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    koopa_cmake_build --prefix="${dict['prefix']}"
    return 0
}
