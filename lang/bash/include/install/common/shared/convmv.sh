#!/usr/bin/env bash

main() {
    # """
    # Install convmv.
    # @note Updated 2023-06-01.
    #
    # @seealso
    # - https://www.j3e.de/linux/convmv/
    # - https://github.com/Homebrew/homebrew-core/blob/HEAD/Formula/convmv.rb
    # """
    local -A app dict
    app['make']="$(koopa_locate_make)"
    koopa_assert_is_executable "${app[@]}"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['url']="https://www.j3e.de/linux/convmv/\
convmv-${dict['version']}.tar.gz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    koopa_print_env
    "${app['make']}" install PREFIX="${dict['prefix']}"
    return 0
}
