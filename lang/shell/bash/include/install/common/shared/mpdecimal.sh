#!/usr/bin/env bash

main() {
    # """
    # Install mpdecimal.
    # @note Updated 2022-09-26.
    # """
    local app dict
    declare -A app=(
        ['make']="$(koopa_locate_make)"
    )
    [[ -x "${app['make']}" ]] || return 1
    declare -A dict=(
        ['name']='mpdecimal'
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
        ['version']="${KOOPA_INSTALL_VERSION:?}"
    )
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
