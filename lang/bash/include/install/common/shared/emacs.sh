#!/usr/bin/env bash

# NOTE Consider building this with macOS framework support, so we can call
# doom-emacs and spacemacs from this.

main() {
    # """
    # Install Emacs.
    # @note Updated 2023-08-30.
    #
    # @seealso
    # - https://emacsformacosx.com/
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/emacs.rb
    # - https://www.emacswiki.org/emacs/EmacsForMacOS
    # - https://emacs.stackexchange.com/questions/28840/
    # """
    local -a conf_args install_args
    local conf_arg
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
    conf_args=(
        # Used in Homebrew formula:
        # > '--with-gnutls'
        # > '--with-xml2'
        # > '--with-tree-sitter'
        '--disable-silent-rules'
        '--with-modules'
        '--without-dbus'
        '--without-imagemagick'
        '--without-ns'
        '--without-selinux'
        '--without-x'
    )
    if koopa_is_macos
    then
        conf_args+=(
            # > '--with-cocoa'
            '--with-ns'
        )
    else
        conf_args+=('--without-ns')
    fi
    for conf_arg in "${conf_args[@]}"
    do
        install_args+=('-D' "$conf_arg")
    done
    koopa_install_gnu_app "${install_args[@]}"
    return 0
}
