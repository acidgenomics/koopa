#!/usr/bin/env bash

koopa::debian_install_docker() { # {{{1
    # """
    # Install Docker.
    # @note Updated 2020-07-30.
    #
    # @seealso
    # - https://docs.docker.com/install/linux/docker-ce/debian/
    # - https://docs.docker.com/install/linux/docker-ce/ubuntu/
    #
    # Currently supports overlay2, aufs and btrfs storage drivers.
    #
    # Configures at '/var/lib/docker/'.
    # """
    local name_fancy pkgs
    koopa::is_docker && return 0
    koopa::is_installed docker && return 0
    name_fancy='Docker'
    koopa::install_start "$name_fancy"
    koopa::assert_has_no_args "$#"
    koopa::apt_add_docker_repo
    # Ready to install Docker.
    pkgs=(
        'containerd.io'
        'docker-ce'
        'docker-ce-cli'
    )
    koopa::apt_install "${pkgs[@]}"
    # Ensure current user is added to Docker group.
    koopa::add_user_to_group 'docker'
    # Move '/var/lib/docker' to '/n/var/lib/docker'.
    koopa::link_docker
    koopa::install_success "$name_fancy"
    koopa::restart
    return 0
}
