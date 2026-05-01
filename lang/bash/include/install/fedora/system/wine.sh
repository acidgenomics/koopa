#!/usr/bin/env bash

main() {
    # """
    # Install Wine.
    # @note Updated 2023-04-05.
    #
    # Note that 'winehq-stable' is currently only available on Fedora 31.
    # Can use 'winehq-devel' on Fedora 32.
    #
    # @seealso
    # - https://wiki.winehq.org/Fedora
    # """
    local -A app dict
    _koopa_asset_is_admin
    app['cut']="$(_koopa_locate_cut --allow-system)"
    _koopa_assert_is_executable "${app[@]}"
    dict['version']="$( \
        _koopa_grep \
            --file='/etc/os-release' \
            --pattern='VERSION_ID=' \
        | "${app['cut']}" -d '=' -f '2' \
    )"
    dict['repo_url']="https://dl.winehq.org/wine-builds/fedora/\
${dict['version']}/winehq.repo"
    _koopa_fedora_dnf update
    _koopa_fedora_dnf_install 'dnf-plugins-core'
    _koopa_fedora_dnf config-manager --add-repo "${dict['repo_url']}"
    _koopa_fedora_dnf_install \
        'winehq-stable' \
        'xorg-x11-apps' \
        'xorg-x11-server-Xvfb' \
        'xorg-x11-xauth'
    return 0
}
