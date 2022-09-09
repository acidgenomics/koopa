#!/usr/bin/env bash

# NOTE Inform user about 'asdf.sh' shell activation.

main() {
    # """
    # Install asdf.
    # @note Updated 2022-08-23.
    #
    # Be aware that symlink into bin currently won't work (2022-06-13).
    # """
    local dict
    declare -A dict=(
        ['name']='asdf'
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
        ['version']="${KOOPA_INSTALL_VERSION:?}"
    )
    dict['libexec']="${dict['prefix']}/libexec"
    dict['file']="v${dict['version']}.tar.gz"
    dict['url']="https://github.com/asdf-vm/${dict['name']}/archive/refs/\
tags/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cp "${dict['name']}-${dict['version']}" "${dict['libexec']}"
    koopa_ln \
        --target-directory="${dict['prefix']}/bin" \
        "${dict['libexec']}/bin/asdf"
    return 0
}
