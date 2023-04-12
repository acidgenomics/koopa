#!/usr/bin/env bash

main() {
    # """
    # Install lz4.
    # @note Updated 2023-04-12.
    #
    # @seealso
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/lz4.rb
    # """
    local -A app dict
    koopa_activate_app --build-only 'make' 'pkg-config'
    app['make']="$(koopa_locate_make)"
    koopa_assert_is_executable "${app[@]}"
    dict['name']='lz4'
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['file']="v${dict['version']}.tar.gz"
    dict['url']="https://github.com/${dict['name']}/${dict['name']}/\
archive/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd "${dict['name']}-${dict['version']}"
    koopa_print_env
    "${app['make']}" install PREFIX="${dict['prefix']}"
    koopa_rm "${dict['prefix']}/lib/"*'.a'
    return 0
}
