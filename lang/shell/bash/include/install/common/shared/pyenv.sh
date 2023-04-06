#!/usr/bin/env bash

main() {
    # """
    # Install pyenv.
    # @note Updated 2023-04-06.
    # """
    local -A dict
    koopa_assert_has_no_args "$#"
    dict['name']='pyenv'
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['file']="v${dict['version']}.tar.gz"
    dict['url']="https://github.com/${dict['name']}/${dict['name']}/archive/\
refs/tags/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cp \
        "${dict['name']}-${dict['version']}" \
        "${dict['prefix']}"
    return 0
}
