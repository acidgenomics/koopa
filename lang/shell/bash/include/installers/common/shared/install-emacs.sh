#!/usr/bin/env bash

main() { # {{{1
    # """
    # Install Emacs.
    # @note Updated 2022-04-20.
    #
    # Consider defining '--enable-locallisppath' and '--infodir' args.
    #
    # @seealso
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/emacs.rb
    # """
    koopa_install_gnu_app \
        --activate-opt='gmp' \
        --activate-opt='gnutls' \
        --activate-opt='libtasn1' \
        --activate-opt='libunistring' \
        --activate-opt='nettle' \
        --activate-opt='pkg-config' \
        --activate-opt='texinfo' \
        --name-fancy='Emacs' \
        --name='emacs' \
        --no-prefix-check \
        --quiet \
        "$@"
    # FIXME Need to assert that Emacs is installed...not actually linking
    # correctly in the current install script for macOS...
}
