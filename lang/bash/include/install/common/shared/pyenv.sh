#!/usr/bin/env bash

main() {
    # """
    # Install pyenv.
    # @note Updated 2023-10-23.
    # """
    local -A dict
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['url']="https://github.com/pyenv/pyenv/archive/refs/tags/\
v${dict['version']}.tar.gz"
    koopa_download "${dict['url']}"
    koopa_extract \
        "$(koopa_basename "${dict['url']}")" \
        "${dict['prefix']}"
    return 0
}
