#!/usr/bin/env bash

main() {
    # """
    # Install Haskell Cabal.
    # @note Updated 2023-06-12.
    # """
    local -A app dict
    app['ghcup']="$(koopa_locate_ghcup)"
    koopa_assert_is_executable "${app[@]}"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    "${app['ghcup']}" install \
        'cabal' "${dict['version']}" \
        --isolate "${dict['prefix']}/bin"
    return 0
}
