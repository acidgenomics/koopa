#!/usr/bin/env bash

main() {
    # """
    # Install diff-so-fancy.
    # @note Updated 2023-08-28.
    #
    # @seealso
    # - https://formulae.brew.sh/formula/diff-so-fancy
    # """
    local -A dict
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['url']="https://github.com/so-fancy/diff-so-fancy/archive/refs/\
tags/v${dict['version']}.tar.gz"
    _koopa_mkdir \
        "${dict['prefix']}/bin" \
        "${dict['prefix']}/libexec"
    _koopa_download "${dict['url']}"
    _koopa_extract "$(_koopa_basename "${dict['url']}")" 'src'
    _koopa_cd 'src'
    _koopa_cp \
        --target-directory="${dict['prefix']}/libexec" \
        'diff-so-fancy' \
        'lib'
    (
        _koopa_cd "${dict['prefix']}/bin"
        _koopa_ln '../libexec/diff-so-fancy' 'diff-so-fancy'
    )
    return 0
}
