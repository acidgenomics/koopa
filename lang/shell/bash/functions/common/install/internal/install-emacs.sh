#!/usr/bin/env bash

# FIXME Need to improve nested call to 'install_app' to avoid double messages
# about install start and stop here.

# FIXME It appears that we need to add gnutls to path more clearly here on
# Debian to get this to install now.

koopa:::install_emacs() { # {{{1
    # """
    # Install Emacs.
    # @note Updated 2021-11-23.
    #
    # Consider defining '--enable-locallisppath' and '--infodir' args.
    # @seealso
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/emacs.rb
    # """
    local conf_args dict install_args pkgs pkgs
    install_args=(
        '--name-fancy=Emacs'
        '--name=emacs'
        '--no-prefix-check'
    )
    conf_args=()
    if koopa::is_linux
    then
        conf_args+=(
            '--with-x-toolkit=no'
            '--with-xpm=no'
        )
    elif koopa::is_macos
    then
        declare -A dict
        dict[gcc_version]="$(koopa::variable 'gcc')"
        dict[gcc_maj_ver]="$(koopa::major_version "${dict[maj_ver]}")"
        pkgs=(
            "gcc@${dict[gcc_maj_ver]}"
            'gnutls'
            'pkg-config'
        )
        # FIXME Support for this needs to be added to our core install handler.
        for pkg in "${pkgs[@]}"
        do
            install_args+=("--homebrew-opt=${pkg}")
        done
        conf_args+=(
            "CC=gcc-${dict[gcc_maj_ver]}"
            '--disable-silent-rules'
            '--with-gnutls'
            '--with-modules'
            '--with-xml2'
            '--without-dbus'
            '--without-imagemagick'
            '--without-ns'
            '--without-selinux'
            '--without-x'
        )
    fi
    koopa::install_gnu_app \
        "${install_args[@]}" \
        "${conf_args[@]}" \
        "$@"
}
