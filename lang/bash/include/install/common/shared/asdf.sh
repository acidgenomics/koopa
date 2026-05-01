#!/usr/bin/env bash

main() {
    # """
    # Install asdf.
    # @note Updated 2023-06-12.
    #
    # Consider informing user about 'asdf.sh' shell activation.
    #
    # Be aware that symlink into bin currently won't work (2022-06-13).
    # """
    local -A dict
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['libexec']="${dict['prefix']}/libexec"
    dict['url']="https://github.com/asdf-vm/asdf/archive/refs/tags/\
v${dict['version']}.tar.gz"
    _koopa_download "${dict['url']}"
    _koopa_extract \
        "$(_koopa_basename "${dict['url']}")" \
        "${dict['libexec']}"
    _koopa_ln \
        --target-directory="${dict['prefix']}/bin" \
        "${dict['libexec']}/bin/asdf"
    return 0
}
