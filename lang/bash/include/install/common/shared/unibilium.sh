#!/usr/bin/env bash

main() {
    # """
    # Install unibilium.
    # @note Updated 2023-06-02.
    #
    # @seealso
    # - https://github.com/Homebrew/homebrew-core/blob/HEAD/
    #     Formula/unibilium.rb
    # """
    local -A app dict
    koopa_activate_app --build-only 'libtool' 'make' 'pkg-config'
    app['make']="$(koopa_locate_make)"
    koopa_assert_is_executable "${app[@]}"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['url']="https://github.com/neovim/unibilium/archive/\
v${dict['version']}.tar.gz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    koopa_print_env
    "${app['make']}"
    "${app['make']}" install PREFIX="${dict['prefix']}"
    return 0
}
