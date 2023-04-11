#!/usr/bin/env bash

main() {
    # """
    # Install Chemacs2.
    # @note Updated 2023-04-06.
    # """
    local -A dict
    dict['commit']="${KOOPA_INSTALL_VERSION:?}"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['url']='https://github.com/plexus/chemacs2.git'
    koopa_git_clone \
        --commit="${dict['commit']}" \
        --prefix="${dict['prefix']}" \
        --url="${dict['url']}"
    return 0
}
