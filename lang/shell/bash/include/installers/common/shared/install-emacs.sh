#!/usr/bin/env bash

main() { # {{{1
    # """
    # Install Emacs.
    # @note Updated 2022-04-22.
    #
    # @seealso
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/emacs.rb
    # """
    local install_args
    install_args=(
        '--activate-build-opt=pkg-config'
        '--activate-opt=gmp'
        '--activate-opt=gnutls'
        '--activate-opt=libtasn1'
        '--activate-opt=libunistring'
        '--activate-opt=libxml2'
        '--activate-opt=nettle'
        '--activate-opt=texinfo'
    )
    if koopa_is_macos
    then
        install_args+=(
            '-D' '--with-modules'
            '-D' '--without-dbus'
            '-D' '--without-imagemagick'
            '-D' '--without-ns'
            '-D' '--without-selinux'
            '-D' '--without-x'
        )
    fi
    koopa_install_gnu_app \
        --name-fancy='Emacs' \
        --name='emacs' \
        --no-prefix-check \
        --quiet \
        "${install_args[@]}" \
        "$@"
}
