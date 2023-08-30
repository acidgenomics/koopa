#!/usr/bin/env bash

main() {
    # """
    # Install csvtk.
    # @note Updated 2023-08-30.
    #
    # @seealso
    # - https://github.com/shenwei356/csvtk
    # - https://github.com/Homebrew/homebrew-core/blob/HEAD/Formula/csvtk.rb
    # """
    local -A dict
    dict['build_cmd']='./csvtk'
    dict['ldflags']='-s -w'
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['url']="https://github.com/shenwei356/csvtk/archive/refs/\
tags/v${dict['version']}.tar.gz"
    koopa_install_go_package \
        --build-cmd="${dict['build_cmd']}" \
        --ldflags="${dict['ldflags']}" \
        --url="${dict['url']}"
    return 0
}
