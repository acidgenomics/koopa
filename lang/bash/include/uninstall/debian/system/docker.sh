#!/usr/bin/env bash

main() {
    # """
    # Uninstall Docker.
    # @note Updated 2021-12-09.
    # """
    local -a pkgs
    pkgs=(
        'containerd.io'
        'docker-ce'
        'docker-ce-cli'
    )
    koopa_debian_apt_remove "${pkgs[@]}"
    koopa_debian_apt_delete_repo 'docker'
    return 0
}
