#!/usr/bin/env bash

main() {
    # """
    # Install shUnit2.
    # @note Updated 2023-06-02.
    # """
    local -A dict
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['url']="https://github.com/kward/shunit2/archive/\
v${dict['version']}.tar.gz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    koopa_cp --target-directory="${dict['prefix']}/bin" 'shunit2'
    return 0
}
