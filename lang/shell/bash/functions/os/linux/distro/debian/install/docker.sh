#!/usr/bin/env bash

koopa::debian_install_docker() { # {{{1
    # """
    # Install Docker.
    # @note Updated 2021-06-04.
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
    name_fancy='Docker'
    if koopa::is_docker
    then
        koopa::alert_note "Can't install ${name_fancy} inside ${name_fancy}."
        return 0
    fi
    if koopa::is_installed 'docker'
    then
        koopa::alert_is_installed "$name_fancy"
        return 0
    fi
    koopa::install_start "$name_fancy"
    koopa::assert_has_no_args "$#"
    koopa::debian_apt_add_docker_repo
    # Ready to install Docker.
    pkgs=(
        'containerd.io'
        'docker-ce'
        'docker-ce-cli'
    )
    koopa::debian_apt_install "${pkgs[@]}"
    # Ensure current user is added to Docker group.
    koopa::add_user_to_group 'docker'
    # Move '/var/lib/docker' to '/n/var/lib/docker'.
    koopa::link_docker
    koopa::install_success "$name_fancy"
    koopa::alert_restart
    return 0
}

koopa::debian_uninstall_docker() { # {{{1
    # """
    # Uninstall Azure CLI.
    # @note Updated 2021-06-11.
    # """
    koopa::stop 'FIXME'
}
