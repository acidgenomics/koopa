#!/usr/bin/env bash

main() {
    # """
    # @seealso
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/bc.rb
    # """
    koopa_activate_app --build-only 'texinfo'
    koopa_activate_app 'ed'
    koopa_install_app_subshell \
        --installer='gnu-app' \
        --name='bc'
}
