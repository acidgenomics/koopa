#!/usr/bin/env bash

main() {
    # """
    # @seealso
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/bc.rb
    # """
    _koopa_activate_app --build-only 'texinfo'
    _koopa_activate_app 'ed'
    _koopa_install_gnu_app
    return 0
}
