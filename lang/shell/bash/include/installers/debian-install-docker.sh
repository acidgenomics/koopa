#!/usr/bin/env bash

koopa:::debian_install_docker() { # {{{1
    # """
    # Install Docker.
    # @note Updated 2021-12-09.
    #
    # @seealso
    # - https://docs.docker.com/install/linux/docker-ce/debian/
    # - https://docs.docker.com/install/linux/docker-ce/ubuntu/
    #
    # Currently supports overlay2, aufs and btrfs storage drivers.
    #
    # Configures at '/var/lib/docker/'.
    # """
    local pkgs
    koopa::assert_has_no_args "$#"
    koopa::debian_apt_add_docker_repo
    pkgs=(
        'docker-ce'
        'docker-ce-cli'
        'containerd.io'
    )
    koopa::debian_apt_install "${pkgs[@]}"
    koopa::linux_add_user_to_group 'docker'
    return 0
}
