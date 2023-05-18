#!/usr/bin/env bash

# NOTE Not currently building this from source.

main() {
    # """
    # Install diff-so-fancy.
    # @note Updated 2023-04-06.
    # """
    local -A dict
    dict['name']='diff-so-fancy'
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['libexec']="${dict['prefix']}/libexec"
    dict['file']="v${dict['version']}.tar.gz"
    dict['url']="https://github.com/so-fancy/${dict['name']}/archive/refs/\
tags/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cp "${dict['name']}-${dict['version']}" "${dict['libexec']}"
    koopa_mkdir "${dict['prefix']}/bin"
    (
        koopa_cd "${dict['prefix']}/bin"
        koopa_ln '../libexec/diff-so-fancy' 'diff-so-fancy'
    )
    return 0
}
