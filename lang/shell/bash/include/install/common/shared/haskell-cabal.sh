#!/usr/bin/env bash

main() {
    # """
    # Install Haskell Cabal.
    # @note Updated 2023-04-06.
    # """
    local -A app dict
    app['ghcup']="$(koopa_locate_ghcup)"
    koopa_assert_is_executable "${app[@]}"
    dict['name']='cabal'
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    "${app['ghcup']}" install \
        "${dict['name']}" "${dict['version']}" \
        --isolate "${dict['prefix']}/bin"
    return 0
}
