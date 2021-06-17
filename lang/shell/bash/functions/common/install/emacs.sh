#!/usr/bin/env bash

# [2021-05-27] macOS success.

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
        --name-fancy='Emacs' \
        --name='emacs' \
        "${install_args[@]}" \
        "${conf_args[@]}" \
        "$@"
}

koopa::link_emacs() { # {{{1
    # """
    # Link Emacs.
    # @note Updated 2020-12-31.
    #
    # Currently supports Doom, Spacemacs, and minimal ESS config.
    # """
    local custom_prefix default_prefix name
    koopa::assert_has_args "$#"
    name="${1:?}"
    default_prefix="$(koopa::emacs_prefix)"
    custom_prefix="${default_prefix}-${name}"
    koopa::assert_is_dir "$custom_prefix"
    if [[ -d "$default_prefix" ]] && [[ ! -L "$default_prefix" ]]
    then
        koopa::stop "Emacs directory detected at '${default_prefix}'."
    fi
    if [[ "$name" != 'minimal' ]]
    then
        koopa::rm "${HOME}/.emacs"
    elif [[ "$name" != 'spacemacs' ]]
    then
        koopa::rm "${HOME}/.spacemacs"
    fi
    case "$name" in
        doom)
            koopa::link_dotfile \
                --force \
                'app/emacs/doom' \
                'doom.d'
            ;;
        minimal)
            koopa::link_dotfile \
                --force \
                'app/emacs/minimal/emacs.el'
            ;;
        spacemacs)
            koopa::link_dotfile \
                --force \
                'app/emacs/spacemacs/spacemacs.el' \
                'spacemacs'
            ;;
        *)
            koopa::stop 'Invalid Emacs config name.'
            ;;
    esac
    koopa::ln "$custom_prefix" "$default_prefix"
    return 0
}

koopa::uninstall_emacs() { # {{{1
    koopa::uninstall_app \
        --name-fancy='Emacs' \
        --name='emacs' \
        "$@"
}
