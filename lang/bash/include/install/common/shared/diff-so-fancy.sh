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
    koopa_mkdir \
        "${dict['prefix']}/bin" \
        "${dict['prefix']}/libexec"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    koopa_cp \
        --target-directory="${dict['prefix']}/libexec" \
        'diff-so-fancy' \
        'lib'
    (
        koopa_cd "${dict['prefix']}/bin"
        koopa_ln '../libexec/diff-so-fancy' 'diff-so-fancy'
    )
    return 0
}
