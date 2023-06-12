#!/usr/bin/env bash

# FIXME Rework to build this from source.

main() {
    # """
    # Install diff-so-fancy.
    # @note Updated 2023-06-12.
    # """
    local -A dict
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['libexec']="${dict['prefix']}/libexec"
    dict['url']="https://github.com/so-fancy/diff-so-fancy/archive/refs/\
tags/v${dict['version']}.tar.gz"
    koopa_download "${dict['url']}"
    koopa_extract \
        "$(koopa_basename "${dict['url']}")" \
        "${dict['libexec']}"
    koopa_mkdir "${dict['prefix']}/bin"
    (
        koopa_cd "${dict['prefix']}/bin"
        koopa_ln '../libexec/diff-so-fancy' 'diff-so-fancy'
    )
    return 0
}
