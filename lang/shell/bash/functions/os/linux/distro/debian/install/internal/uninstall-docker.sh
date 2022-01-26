#!/usr/bin/env bash

koopa:::debian_uninstall_docker() { # {{{1
    # """
    # Uninstall Docker.
    # @note Updated 2021-12-09.
    # """
    local pkgs
    koopa::assert_has_no_args "$#"
    pkgs=(
        'containerd.io'
        'docker-ce'
        'docker-ce-cli'
    )
    koopa::debian_apt_remove "${pkgs[@]}"
    koopa::debian_apt_delete_repo 'docker'
    return 0
}
