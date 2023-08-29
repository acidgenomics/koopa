#!/usr/bin/env bash

main() {
    # """
    # Install yq.
    # @note Updated 2023-08-29.
    #
    # @seealso
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/yq.rb
    # - go help build
    # """
    local -A dict
    dict['name']="${KOOPA_INSTALL_NAME:?}"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['url']="https://github.com/mikefarah/yq/archive/\
v${dict['version']}.tar.gz"
    koopa_install_go_package \
        --name="${dict['name']}" \
        --prefix="${dict['prefix']}" \
        --url="${dict['url']}" \
        --version="${dict['version']}"
    return 0
}
