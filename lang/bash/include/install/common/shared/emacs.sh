#!/usr/bin/env bash

main() {
    # """
    # Install Emacs.
    # @note Updated 2024-01-19.
    #
    # @seealso
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/emacs.rb
    # - https://emacsformacosx.com/
    # - https://github.com/caldwell/build-emacs/
    # - https://github.com/caldwell/build-emacs/blob/master/build-emacs-from-tar
    # - https://github.com/jimeh/build-emacs-for-macos/
    # - https://github.com/d12frosted/homebrew-emacs-plus
    # - https://www.emacswiki.org/emacs/EmacsForMacOS
    # - https://emacs.stackexchange.com/questions/28840/
    # """
    local -a conf_args deps install_args
    local conf_arg
    deps+=(
        'gmp'
        'ncurses'
        'libtasn1'
        'libunistring'
        'icu4c75' # libxml2
        'libxml2'
        'nettle'
        'texinfo'
        'gnutls'
    )
    koopa_activate_app --build-only 'pkg-config'
    koopa_activate_app "${deps[@]}"
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
        conf_args+=('--without-ns')
    fi
    for conf_arg in "${conf_args[@]}"
    do
        install_args+=('-D' "$conf_arg")
    done
    koopa_install_gnu_app "${install_args[@]}"
    return 0
}
