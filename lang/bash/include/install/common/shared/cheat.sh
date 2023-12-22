#!/usr/bin/env bash

main() {
    # """
    # Install cheat.
    # @note Updated 2023-12-22.
    #
    # @seealso
    # - https://github.com/cheat/cheat/
    # - https://formulae.brew.sh/formula/cheat
    # """
    local -A dict
    dict['build_cmd']='./cmd/cheat'
    dict['mod']='vendor'
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['url']="https://github.com/cheat/cheat/archive/refs/tags/\
${dict['version']}.tar.gz"
    koopa_build_go_package \
        --build-cmd="${dict['build_cmd']}" \
        --mod="${dict['mod']}" \
        --url="${dict['url']}"
    return 0
}
