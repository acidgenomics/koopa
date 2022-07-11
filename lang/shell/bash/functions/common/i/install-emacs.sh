#!/usr/bin/env bash

# FIXME Need to address this:
# checking for library containing tputs... no
# configure: error: The required function 'tputs' was not found in any library.
# The following libraries were tried (in order):
#   libtinfo, libncurses, libterminfo, libcurses, libtermcap
# Please try installing whichever of these libraries is most appropriate
# for your system, together with its header files.
# For example, a libncurses-dev(el) or similar package.

koopa_install_emacs() {
    # """
    # @seealso
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/emacs.rb
    # """
    local install_args
    install_args=(
        '--activate-opt=gmp'
        '--activate-opt=ncurses'
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
