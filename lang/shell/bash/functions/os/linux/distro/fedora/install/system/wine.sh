#!/usr/bin/env bash

# FIXME Consider defining 'koopa::cut' function to wrap the cut call here.
koopa::fedora_install_wine() { # {{{1
    # """
    # Install Wine.
    # @note Updated 2021-10-25.
    #
    # Note that 'winehq-stable' is currently only available on Fedora 31.
    # Can use 'winehq-devel' on Fedora 32.
    #
    # @seealso
    # - https://wiki.winehq.org/Fedora
    # """
    local app name_fancy repo_url version
    name_fancy='Wine'
    koopa::install_start "$name_fancy"
    if koopa::is_installed 'wine'
    then
        koopa::alert_is_installed "$name_fancy"
        return 0
    fi
    declare -A app=(
        [cut]="$(koopa::locate_cut)"
    )
    version="$( \
        koopa::grep 'VERSION_ID=' '/etc/os-release' \
            | "${app[cut]}" -d '=' -f 2 \
    )"
    repo_url="https://dl.winehq.org/wine-builds/fedora/${version}/winehq.repo"
    koopa::fedora_dnf update
    koopa::fedora_dnf_install 'dnf-plugins-core'
    koopa::fedora_dnf config-manager --add-repo "$repo_url"
    koopa::fedora_dnf_install \
        'winehq-stable' \
        'xorg-x11-apps' \
        'xorg-x11-server-Xvfb' \
        'xorg-x11-xauth'
    koopa::install_success "$name_fancy"
    return 0
}

koopa::fedora_uninstall_wine() { # {{{1
    # """
    # Uninstall Wine.
    # @note Updated 2021-06-17.
    # """
    koopa::fedora_dnf_remove \
        'winehq-stable' \
        'xorg-x11-apps' \
        'xorg-x11-server-Xvfb' \
        'xorg-x11-xauth'
    koopa::fedora_dnf_delete_repo 'winehq'
    return 0
}
