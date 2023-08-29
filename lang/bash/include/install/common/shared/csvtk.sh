#!/usr/bin/env bash

main() {
    # """
    # Install csvtk.
    # @note Updated 2023-08-28.
    #
    # @seealso
    # - https://github.com/shenwei356/csvtk
    # - https://github.com/Homebrew/homebrew-core/blob/HEAD/Formula/csvtk.rb
    # """
    local -A dict
    dict['name']="${KOOPA_INSTALL_NAME:?}"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['url']="https://github.com/shenwei356/csvtk/archive/refs/\
tags/v${dict['version']}.tar.gz"
    koopa_install_go_package \
        --build-cmd='./csvtk' \
        --ldflags='-s -w' \
        --name="${dict['name']}" \
        --prefix="${dict['prefix']}" \
        --url="${dict['url']}" \
        --version="${dict['version']}"
    return 0
}
