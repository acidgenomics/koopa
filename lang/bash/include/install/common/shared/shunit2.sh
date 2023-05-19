#!/usr/bin/env bash

main() {
    # """
    # Install shUnit2.
    # @note Updated 2023-04-06.
    # """
    local -A dict
    dict['name']='shunit2'
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['file']="v${dict['version']}.tar.gz"
    dict['url']="https://github.com/kward/${dict['name']}/archive/\
${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd "${dict['name']}-${dict['version']}"
    koopa_cp --target-directory="${dict['prefix']}/bin" "${dict['name']}"
    return 0
}
