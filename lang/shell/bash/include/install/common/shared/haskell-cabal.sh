#!/usr/bin/env bash

main() {
    # """
    # Install Haskell Cabal.
    # @note Updated 2022-11-15.
    # """
    local app dict
    koopa_assert_has_no_args "$#"
    local -A app
    app['ghcup']="$(koopa_locate_ghcup)"
    [[ -x "${app['ghcup']}" ]] || exit 1
    local -A dict=(
        ['name']='cabal'
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
        ['version']="${KOOPA_INSTALL_VERSION:?}"
    )
    "${app['ghcup']}" install \
        "${dict['name']}" "${dict['version']}" \
        --isolate "${dict['prefix']}/bin"
    return 0
}
