#!/usr/bin/env bash

main() {
    # """
    # Install ShellCheck.
    # @note Updated 2023-08-30.
    #
    # @seealso
    # - https://hackage.haskell.org/package/ShellCheck
    # - https://github.com/koalaman/shellcheck/blob/master/ShellCheck.cabal
    # """
    koopa_install_haskell_package --name='ShellCheck'
    return 0
}
