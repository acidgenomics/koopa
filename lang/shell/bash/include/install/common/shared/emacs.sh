#!/usr/bin/env bash

# FIXME Can we build this with macOS framework support, so we can call
# doom-emacs and spacemacs from this, rather than system Emacs?

main() {
    # """
    # @seealso
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/emacs.rb
    # """
    koopa_activate_opt_prefix \
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
        '-D' '--with-modules' \
        '-D' '--without-dbus' \
        '-D' '--without-imagemagick' \
        '-D' '--without-ns' \
        '-D' '--without-selinux' \
        '-D' '--without-x' \
        "$@"
}
