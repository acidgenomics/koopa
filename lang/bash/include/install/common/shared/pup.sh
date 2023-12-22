#!/usr/bin/env bash

main() {
    # """
    # Install pup.
    # @note Updated 2023-12-22.
    #
    # @seealso
    # - https://github.com/ericchiang/pup
    # - https://formulae.brew.sh/formula/pup
    # """
    local -A dict
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['url']="github.com/ericchiang/pup@v${dict['version']}"
    koopa_install_go_package --url="${dict['url']}"
    return 0
}
