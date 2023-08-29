#!/usr/bin/env bash

main() {
    # """
    # Install cheat.
    # @note Updated 2023-08-29.
    #
    # @seealso
    # - https://github.com/cheat/cheat/
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/cheat.rb
    # """
    local -A dict
    dict['name']="${KOOPA_INSTALL_NAME:?}"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['url']="https://github.com/cheat/cheat/archive/refs/tags/\
${dict['version']}.tar.gz"
    koopa_install_go_package \
        --build-cmd='./cmd/cheat' \
        --mod='vendor' \
        --name="${dict['name']}" \
        --prefix="${dict['prefix']}" \
        --url="${dict['url']}" \
        --version="${dict['version']}"
    return 0
}
