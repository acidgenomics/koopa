#!/usr/bin/env bash

install_from_conda() {
    koopa_install_conda_package
    return 0
}

install_from_haskell() {
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

main() {
    install_from_conda
    return 0
}
