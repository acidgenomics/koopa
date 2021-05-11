#!/usr/bin/env bash

koopa::install_emacs() { # {{{1
    # """
    # Install Emacs.
    # @note Updated 2021-05-10.
    #
    # Consider defining '--enable-locallisppath' and '--infodir' args.
    # @seealso
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/emacs.rb
    # """
    local conf_args gcc_version install_args pkgs pkgs_string
    install_args=()
    conf_args=()
    if koopa::is_linux
    then
        conf_args+=(
            '--with-x-toolkit=no'
            '--with-xpm=no'
        )
    elif koopa::is_macos
    then
        gcc_version="$(koopa::variable 'gcc')"
        gcc_version="$(koopa::major_version "$gcc_version")"
        pkgs=(
            "gcc@${gcc_version}"
            'gnutls'
            'pkg-config'
        )
        pkgs_string="$(koopa::paste0 ',' "${pkgs[@]}")"
        install_args+=(
            "--homebrew-opt=${pkgs_string}"
        )
        conf_args+=(
            "CC=gcc-${gcc_version}"
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
        --name='emacs' \
        --name-fancy='Emacs' \
        "${install_args[@]}" \
        "${conf_args[@]}" \
        "$@"
}

koopa::update_emacs() { # {{{1
    # """
    # Update Emacs.
    # @note Updated 2020-11-25.
    # """
    koopa::assert_has_no_args "$#"
    if ! koopa::is_installed emacs
    then
        koopa::alert_not_installed 'emacs'
        return 0
    fi
    if koopa::is_spacemacs_installed
    then
        koopa:::update_spacemacs
    elif koopa::is_doom_emacs_installed
    then
        koopa:::update_doom_emacs
    else
        koopa::alert_note 'Emacs configuration cannot be updated.'
        return 0
    fi
    return 0
}
