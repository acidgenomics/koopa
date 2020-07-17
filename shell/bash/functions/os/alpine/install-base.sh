#!/usr/bin/env bash

koopa::alpine_install_base() { # {{{1
    # """
    # Install Alpine Linux base system.
    # @note Updated 2020-07-16.
    #
    # Potentially useful flags:
    # > apk add --no-cache --virtual .build-dependencies
    # """
    local name_fancy packages
    koopa::assert_is_installed apk sudo
    name_fancy='Alpine base system'
    koopa::install_start "$name_fancy"
    sudo apk update
    sudo apk upgrade
    packages=(
        # .build-dependencies
        # R-dev
        # R-doc
        # fish
        # pandoc
        # pandoc-citeproc
        # texlive
        # zsh
        'R'
        'autoconf'
        'bash'
        'bash-completion'
        'build-base'
        'ca-certificates'
        'curl'
        'dpkg'
        'gettext'
        'git'
        'libevent-dev'
        'libffi-dev'
        'libxml2-dev'
        'mdocml'
        'openssl'
        'shadow'
        'sudo'
        'tcl'
        'tree'
        'wget'
    )
    sudo apk add --no-cache --virtual "${packages[@]}"
    koopa::install_success "$name_fancy"
    return 0
}

