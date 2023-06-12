#!/usr/bin/env bash

# NOTE Consider building this with macOS framework support, so we can call
# doom-emacs and spacemacs from this.

# FIXME This isn't setting gnutls correctly on Linux.

main() {
    # """
    # @seealso
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/emacs.rb
    # """
    koopa_activate_app --build-only 'pkg-config'
    koopa_activate_app \
        'gmp' \
        'ncurses' \
        'libtasn1' \
        'libunistring' \
        'libxml2' \
        'nettle' \
        'texinfo' \
        'gnutls'
    koopa_install_app_subshell \
        --installer='gnu-app' \
        --name='emacs' \
        '-D' '--with-gnutls' \
        '-D' '--with-modules' \
        '-D' '--without-dbus' \
        '-D' '--without-imagemagick' \
        '-D' '--without-ns' \
        '-D' '--without-selinux' \
        '-D' '--without-x'
}
