#!/usr/bin/env bash

main() {
    # """
    # Install c-ares.
    # @note Updated 2023-04-06.
    #
    # @seealso
    # - https://c-ares.org/
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/c-ares.rb
    # """
    local -A dict
    koopa_activate_app --build-only 'pkg-config'
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['url']="https://c-ares.org/download/c-ares-${dict['version']}.tar.gz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    koopa_cmake_build --prefix="${dict['prefix']}"
    return 0
}
