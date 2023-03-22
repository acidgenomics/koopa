#!/usr/bin/env bash

# FIXME This requires 'ed' to be installed on Ubuntu 20.

main() {
    # """
    # @seealso
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/bc.rb
    # """
    koopa_activate_app --build-only 'texinfo'
    koopa_install_app_subshell \
        --installer='gnu-app' \
        --name='bc' \
        "$@"
}
