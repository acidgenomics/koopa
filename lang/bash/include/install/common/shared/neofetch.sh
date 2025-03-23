#!/usr/bin/env bash

main() {
    # """
    # Install neofetch.
    # @note Updated 2023-06-01.
    # """
    local -A app dict
    app['make']="$(koopa_locate_make)"
    koopa_assert_is_executable "${app[@]}"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['url']="https://github.com/dylanaraps/neofetch/archive/\
${dict['version']}.tar.gz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    koopa_print_env
    "${app['make']}" PREFIX="${dict['prefix']}" install
    return 0
}
