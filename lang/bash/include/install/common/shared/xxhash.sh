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
    _koopa_activate_app --build-only 'make' 'pkg-config'
    app['make']="$(_koopa_locate_make)"
    _koopa_assert_is_executable "${app[@]}"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['url']="https://github.com/Cyan4973/xxHash/\
archive/v${dict['version']}.tar.gz"
    _koopa_download "${dict['url']}"
    _koopa_extract "$(_koopa_basename "${dict['url']}")" 'src'
    _koopa_cd 'src'
    _koopa_print_env
    "${app['make']}" install PREFIX="${dict['prefix']}"
    _koopa_rm "${dict['prefix']}/lib/"*'.a'
    return 0
}
