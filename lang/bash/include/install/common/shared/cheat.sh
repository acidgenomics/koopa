#!/usr/bin/env bash

main() {
    # """
    # Install cheat.
    # @note Updated 2023-08-30.
    #
    # @seealso
    # - https://github.com/cheat/cheat/
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/cheat.rb
    # """
    local -A dict
    dict['build_cmd']='./cmd/cheat'
    dict['mod']='vendor'
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['url']="https://github.com/cheat/cheat/archive/refs/tags/\
${dict['version']}.tar.gz"
    koopa_install_go_package \
        --build-cmd="${dict['build_cmd']}" \
        --mod="${dict['mod']}" \
        --url="${dict['url']}"
    return 0
}
