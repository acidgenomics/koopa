#!/usr/bin/env bash

koopa:::fedora_install_wine() { # {{{1
    # """
    # Install Wine.
    # @note Updated 2022-01-27.
    #
    # Note that 'winehq-stable' is currently only available on Fedora 31.
    # Can use 'winehq-devel' on Fedora 32.
    #
    # @seealso
    # - https://wiki.winehq.org/Fedora
    # """
    local app dict
    koopa::assert_has_no_args "$#"
    koopa::asset_is_admin
    declare -A app=(
        [cut]="$(koopa::locate_cut)"
    )
    declare -A dict
    dict[version]="$( \
        koopa::grep 'VERSION_ID=' '/etc/os-release' \
            | "${app[cut]}" -d '=' -f 2 \
    )"
    dict[repo_url]="https://dl.winehq.org/wine-builds/fedora/\
${dict[version]}/winehq.repo"
    koopa::fedora_dnf update
    koopa::fedora_dnf_install 'dnf-plugins-core'
    koopa::fedora_dnf config-manager --add-repo "${dict[repo_url]}"
    koopa::fedora_dnf_install \
        'winehq-stable' \
        'xorg-x11-apps' \
        'xorg-x11-server-Xvfb' \
        'xorg-x11-xauth'
    return 0
}
