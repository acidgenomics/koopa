#!/usr/bin/env bash

main() {
    # """
    # Install walk.
    # @note Updated 2023-08-30.
    #
    # @seealso
    # - https://github.com/antonmedv/walk/
    # """
    local -A dict
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['url']="https://github.com/antonmedv/walk/archive/refs/tags/\
v${dict['version']}.tar.gz"
    koopa_install_go_package --url="${dict['url']}"
    return 0
}
