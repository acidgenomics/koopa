#!/usr/bin/env bash

main() {
    # """
    # Install walk.
    # @note Updated 2023-12-22.
    #
    # @seealso
    # - https://github.com/antonmedv/walk/
    # - https://formulae.brew.sh/formula/walk
    # """
    local -A dict
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['url']="github.com/antonmedv/walk@v${dict['version']}"
    koopa_install_go_package --url="${dict['url']}"
    return 0
}
