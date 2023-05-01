#!/usr/bin/env bash

main() {
    # """
    # Install minimap2.
    # @note Updated 2023-05-01.
    #
    # @seealso
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/
    #     minimap2.rb
    # - https://github.com/bioconda/bioconda-recipes/tree/master/recipes/
    #     minimap2
    # """
    #
    local -A app dict
    koopa_activate_app 'zlib'
    app['make']="$(koopa_locate_make)"
    koopa_assert_is_executable "${app[@]}"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['url']="https://github.com/lh3/minimap2/archive/refs/tags/\
v${dict['version']}.tar.gz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    koopa_print_env
    "${app['make']}" VERBOSE=1
    koopa_cp --target-directory="${dict['prefix']}/bin" 'minimap2'
    return 0
}
