#!/usr/bin/env bash

# FIXME Consider installing this per user instead of for all users.

main() {
    # """
    # Install pyenv.
    # @note Updated 2025-04-29.
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
    koopa_mkdir \
        "${dict['prefix']}/shims" \
        "${dict['prefix']}/versions"
    koopa_chmod 0777 \
        "${dict['prefix']}/shims" \
        "${dict['prefix']}/versions"
    return 0
}
