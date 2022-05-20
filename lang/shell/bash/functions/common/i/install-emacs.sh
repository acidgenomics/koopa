#!/usr/bin/env bash

koopa_install_emacs() {
    # """
    # @seealso
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/emacs.rb
    # """
    local install_args
    install_args=(
        '--activate-opt=gmp'
        '--activate-opt=libtasn1'
        '--activate-opt=libunistring'
        '--activate-opt=libxml2'
        '--activate-opt=nettle'
        '--activate-opt=texinfo'
        '--activate-opt=gnutls'
        '--installer=gnu-app'
        '--name-fancy=Emacs'
        '--name=emacs'
        '-D' '--with-modules'
        '-D' '--without-dbus'
        '-D' '--without-imagemagick'
        '-D' '--without-ns'
        '-D' '--without-selinux'
        '-D' '--without-x'
    )
    # Assume we're using Emacs cask by default on macOS.
    if ! koopa_is_macos
    then
        install_args+=('--link-in-bin=bin/emacs')
    fi
    koopa_install_app "${install_args[@]}" "$@"
}
