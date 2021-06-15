#!/usr/bin/env bash

koopa::fedora_dnf() { # {{{1
    # """
    # Use either 'dnf' or 'yum' to manage packages.
    # @note Updated 2021-06-15.
    # """
    local app
    if koopa::is_installed 'dnf'
    then
        app='dnf'
    elif koopa::is_installed 'yum'
    then
        app='yum'
    else
        koopa::stop "Failed to locate package manager (e.g. 'dnf' or 'yum')."
    fi
    sudo "$app" -y "$@"
    return 0
}

koopa::fedora_dnf_install() { # {{{1
    koopa::fedora_dnf install "$@"
}

koopa::fedora_dnf_remove() { # {{{1
    koopa::fedora_dnf remove "$@"
}
