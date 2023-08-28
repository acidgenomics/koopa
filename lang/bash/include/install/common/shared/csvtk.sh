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
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['url']="https://github.com/shenwei356/csvtk/archive/refs/\
tags/v${dict['version']}.tar.gz"
    koopa_install_app_subshell \
        --installer='go-package' \
        --name='csvtk' \
        -D '--build-cmd=./csvtk' \
        -D '--ldflags=-s -w' \
        -D "--url=${dict['url']}"
    return 0
}
