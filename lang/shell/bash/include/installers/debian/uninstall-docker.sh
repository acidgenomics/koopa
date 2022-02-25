#!/usr/bin/env bash

debian_uninstall_docker() { # {{{1
    # """
    # Uninstall Docker.
    # @note Updated 2021-12-09.
    # """
    local pkgs
    koopa_assert_has_no_args "$#"
    koopa_assert_is_admin
    pkgs=(
        'containerd.io'
        'docker-ce'
        'docker-ce-cli'
    )
    koopa_debian_apt_remove "${pkgs[@]}"
    koopa_debian_apt_delete_repo 'docker'
    return 0
}
