#!/usr/bin/env bash

main() {
    # """
    # Install Go.
    # @note Updated 2023-06-01.
    #
    # @seealso
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/go.rb
    # """
    local -A dict
    dict['arch']="$(koopa_arch2)" # e.g. "amd64".
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    if koopa_is_macos
    then
        dict['os_id']='darwin'
    else
        dict['os_id']='linux'
    fi
    dict['url']="https://dl.google.com/go/\
go${dict['version']}.${dict['os_id']}-${dict['arch']}.tar.gz"
    koopa_download "${dict['url']}"
    koopa_extract \
        "$(koopa_basename "${dict['url']}")" \
        "${dict['prefix']}"
    koopa_assert_is_installed "${dict['prefix']}/bin/go"
    return 0
}
