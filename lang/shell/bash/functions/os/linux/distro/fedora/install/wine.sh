#!/usr/bin/env bash

koopa::fedora_install_wine() { # {{{1
    # """
    # Install Wine.
    # @note Updated 2020-07-30.
    #
    # Note that 'winehq-stable' is currently only available on Fedora 31.
    # Can use 'winehq-devel' on Fedora 32.
    #
    # @seealso
    # - https://wiki.winehq.org/Fedora
    # """
    local name_fancy repo_url version
    name_fancy='Wine'
    if koopa::is_installed 'wine'
    then
        koopa::alert_is_installed "$name_fancy"
        return 0
    fi
    koopa::install_start "$name_fancy"
    version="$( \
        grep 'VERSION_ID=' '/etc/os-release' \
            | cut -d '=' -f 2 \
    )"
    repo_url="https://dl.winehq.org/wine-builds/fedora/${version}/winehq.repo"
    dnf -y update
    dnf -y install dnf-plugins-core
    dnf config-manager --add-repo "$repo_url"
    dnf -y install \
        winehq-stable \
        xorg-x11-apps \
        xorg-x11-server-Xvfb \
        xorg-x11-xauth
    koopa::install_success "$name_fancy"
    return 0
}

