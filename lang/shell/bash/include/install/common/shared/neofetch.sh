#!/usr/bin/env bash

main() {
    # """
    # Install neofetch.
    # @note Updated 2023-04-06.
    # """
    local -A app dict
    app['make']="$(koopa_locate_make)"
    koopa_assert_is_executable "${app[@]}"
    dict['name']='neofetch'
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['file']="${dict['version']}.tar.gz"
    dict['url']="https://github.com/dylanaraps/${dict['name']}/\
archive/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd "${dict['name']}-${dict['version']}"
    koopa_mkdir "${dict['prefix']}"
    koopa_print_env
    "${app['make']}" PREFIX="${dict['prefix']}" install
    return 0
}
