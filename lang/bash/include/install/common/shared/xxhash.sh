#!/usr/bin/env bash

main() {
    # """
    # Install xxhash.
    # @note Updated 2023-04-11.
    #
    # @seealso
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/xxhash.rb
    # """
    local -A app dict
    koopa_activate_app --build-only 'make' 'pkg-config'
    app['make']="$(koopa_locate_make)"
    koopa_assert_is_executable "${app[@]}"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['url']="https://github.com/Cyan4973/xxHash/\
archive/v${dict['version']}.tar.gz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    koopa_print_env
    "${app['make']}" install PREFIX="${dict['prefix']}"
    koopa_rm "${dict['prefix']}/lib/"*'.a'
    return 0
}
