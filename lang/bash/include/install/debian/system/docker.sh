#!/usr/bin/env bash

# FIXME Rework to use this general approach:
# > apt update
# > snap install docker
# > apt install -y docker.io
# > groupadd -f docker
# > usermod -aG docker "$USER"
# > newgrp docker
# > service docker start

main() {
    # """
    # Install Docker.
    # @note Updated 2025-01-15.
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
