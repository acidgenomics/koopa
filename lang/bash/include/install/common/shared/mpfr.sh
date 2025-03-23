#!/usr/bin/env bash

# NOTE Need to apply patches for this.

main() {
    # """
    # Install mpfr.
    # @note Updated 2023-08-30.
    #
    # @seealso
    # - https://github.com/Homebrew/homebrew-core/blob/HEAD/Formula/mpfr.rb
    # """
    koopa_activate_app 'gmp'
    koopa_install_gnu_app -D '--disable-static'
    return 0
}
