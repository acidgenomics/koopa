#!/usr/bin/env bash

main() {
    # """
    # Install convmv.
    # @note Updated 2023-04-06.
    #
    # @seealso
    # - https://www.j3e.de/linux/convmv/
    # - https://github.com/Homebrew/homebrew-core/blob/HEAD/Formula/convmv.rb
    # """
    local -A app dict
    app['make']="$(koopa_locate_make)"
    koopa_assert_is_executable "${app[@]}"
    dict['name']='convmv'
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['file']="${dict['name']}-${dict['version']}.tar.gz"
    dict['url']="https://www.j3e.de/linux/${dict['name']}/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd "${dict['name']}-${dict['version']}"
    koopa_print_env
    "${app['make']}" install PREFIX="${dict['prefix']}"
    return 0
}
