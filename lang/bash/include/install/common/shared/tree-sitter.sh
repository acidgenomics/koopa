#!/usr/bin/env bash

main() {
    # """
    # Install tree-sitter.
    # @note Updated 2024-03-11.
    #
    # @seealso
    # - https://github.com/Homebrew/homebrew-core/blob/HEAD/
    #     Formula/tree-sitter.rb
    # """
    local -A app dict
    koopa_activate_app --build-only 'make' 'pkg-config'
    app['install']="$(koopa_locate_install)"
    app['make']="$(koopa_locate_make)"
    koopa_assert_is_executable "${app[@]}"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['url']="https://github.com/tree-sitter/tree-sitter/archive/refs/\
tags/v${dict['version']}.tar.gz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    # Currently fails due to '-D' usage otherwise with BSD install.
    dict['bin_prefix']="$(koopa_init_dir 'bin')"
    koopa_ln "${app['install']}" "${dict['bin_prefix']}/install"
    koopa_add_to_path_start "${dict['bin_prefix']}"
    koopa_cd 'src'
    koopa_print_env
    "${app['make']}" AMALGAMATED=1
    "${app['make']}" install PREFIX="${dict['prefix']}"
    return 0
}
