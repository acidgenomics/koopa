#!/usr/bin/env bash

main() {
    # """
    # Install llama.
    # @note Updated 2023-08-29.
    #
    # @seealso
    # - https://github.com/Homebrew/homebrew-core/blob/HEAD/Formula/llama.rb
    # """
    local -A dict
    dict['name']="${KOOPA_INSTALL_NAME:?}"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['ldflags']='-s -w'
    dict['url']="https://github.com/antonmedv/llama/archive/refs/tags/\
v${dict['version']}.tar.gz"
    koopa_install_go_package \
        --ldflags="${dict['ldflags']}" \
        --name="${dict['name']}" \
        --prefix="${dict['prefix']}" \
        --url="${dict['url']}" \
        --version="${dict['version']}"
    return 0
}
