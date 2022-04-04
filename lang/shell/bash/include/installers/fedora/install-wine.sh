#!/usr/bin/env bash

# FIXME Indicate that this is a binary install.

fedora_install_wine() { # {{{1
    # """
    # Install Wine.
    # @note Updated 2022-02-23.
    #
    # Note that 'winehq-stable' is currently only available on Fedora 31.
    # Can use 'winehq-devel' on Fedora 32.
    #
    # @seealso
    # - https://wiki.winehq.org/Fedora
    # """
    local app dict
    koopa_assert_has_no_args "$#"
    koopa_asset_is_admin
    declare -A app=(
        [cut]="$(koopa_locate_cut)"
    )
    declare -A dict
    dict[version]="$( \
        koopa_grep \
            --file='/etc/os-release' \
            --pattern='VERSION_ID=' \
        | "${app[cut]}" --delimiter='=' --fields='2' \
    )"
    dict[repo_url]="https://dl.winehq.org/wine-builds/fedora/\
${dict[version]}/winehq.repo"
    koopa_fedora_dnf update
    koopa_fedora_dnf_install 'dnf-plugins-core'
    koopa_fedora_dnf config-manager --add-repo "${dict[repo_url]}"
    koopa_fedora_dnf_install \
        'winehq-stable' \
        'xorg-x11-apps' \
        'xorg-x11-server-Xvfb' \
        'xorg-x11-xauth'
    return 0
}
