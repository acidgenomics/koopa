#!/usr/bin/env bash

main() {
    # """
    # Install hadolint.
    # @note Updated 2023-08-30.
    #
    # @seealso
    # - https://hackage.haskell.org/package/hadolint
    # - https://github.com/hadolint/hadolint
    # - https://formulae.brew.sh/formula/hadolint
    # - https://github.com/hadolint/hadolint/issues/904
    # """
    koopa_install_haskell_package --ghc-version='9.2.8'
    return 0
}
