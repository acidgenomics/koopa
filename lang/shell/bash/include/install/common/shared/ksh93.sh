#!/usr/bin/env bash

main() {
    # """
    # Install KornShell, ksh93.
    # @note Updated 2023-04-12.
    #
    # @seealso
    # - https://github.com/ksh93/ksh
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/ksh93.rb
    # """
    local -A dict
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['url']="https://github.com/ksh93/ksh/archive/refs/tags/\
v${dict['version']}.tar.gz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    ./bin/package help || true
    ./bin/package verbose make
    ./bin/package verbose install "${dict['prefix']}"
    return 0
}
