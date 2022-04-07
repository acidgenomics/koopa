#!/usr/bin/env bash

# FIXME Indicate that this is a binary install.

main() { # {{{1
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
    koopa_assert_has_no_args "$#"
    koopa_assert_is_admin
    koopa_debian_apt_add_docker_repo
    pkgs=(
        'docker-ce'
        'docker-ce-cli'
        'containerd.io'
    )
    koopa_debian_apt_install "${pkgs[@]}"
    koopa_linux_add_user_to_group 'docker'
    return 0
}
