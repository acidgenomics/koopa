#!/usr/bin/env bash

main() {
    # """
    # Install mpdecimal.
    # @note Updated 2023-04-06.
    # """
    local -A app dict
    koopa_activate_app --build-only 'make'
    app['make']="$(koopa_locate_make)"
    koopa_assert_is_executable "${app[@]}"
    dict['name']='mpdecimal'
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['file']="${dict['name']}-${dict['version']}.tar.gz"
    dict['url']="https://www.bytereef.org/software/${dict['name']}/\
releases/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd "${dict['name']}-${dict['version']}"
    ./configure --prefix="${dict['prefix']}"
    "${app['make']}"
    "${app['make']}" install
    return 0
}
